clear

%%
close all

zscale1=1.7*1.e3; % peak updraft velocity altitude
zscale2=2.7*1.e3; % top of the plume
dt=1;

zp=0:25:3000;
xp=0:50:9000;

pz=101300*exp(-9.8*0.029*zp/(8.314*298));
rho=pz./(287*298);

dzp=[zp(2:end) zp(end)];
dxp=[xp(2:end) xp(end)];

nz=length(zp)-1;
nx=length(xp)-1;
phi=zeros(nx+1,nz+1);

AMPL0=1.0;
AMPL20=0;
xscale0=1.8*1.e3;
xscale1=xscale0/4;
AMPA=3.5;
AMPB=3.0;
AMP2A=0.6*1.e3;
AMP2B=0.5*1.e3;
tscale1=600;
tscale2=900;

zer0=1.07687398631180;
zer1=5.38572965402801;
xt=3.64359716742540;
mx=0.5*xscale0/(zer1-xt);
xdisp=4500-zer1*mx;
x1r=zer1*mx;
my=x1r^2*cos(x1r/mx);

for t=1%1:3600
   
   if t<300
      AMPL=AMPL0;
      AMPL2=AMPL20;
      xscale=xscale0;
      
   elseif t>=300 && t<900
      AMPL=AMPL0;
      AMPL2=AMP2A*(cos(pi*((t-300.)/tscale1 - 1.)) + 1.);
      xscale=xscale0;
      
   elseif t>=900 && t<1500
      MPL=AMPA*(cos(pi*((t-900.)/tscale1 + 1.)) +1.) + AMPL0;
      AMPL2=AMP2A*(cos(pi*((t-300.)/tscale1 - 1.)) + 1.);
      xscale=xscale0;
   elseif t>=1500 && t<2100
      AMPL=AMPB*(cos(pi*(t-1500.)/tscale2) +1.) + 2.*AMPL0;
      AMPL2=AMP2B*(cos(pi*((t-1500.)/tscale2 - 1.)) + 1.);
      xscale=xscale0;
   elseif t>=2100 && t<2400
      AMPL=AMPB*(cos(pi*(t-1500.)/tscale2) +1.) + 2.*AMPL0;
      AMPL2=AMP2B*(cos(pi*((t-1500.)/tscale2 - 1.)) + 1.);
      xscale=xscale0;
   else
      t1=2400.;
      AMPL=AMPB*(cos(pi*(t1-1500.)/tscale2) +1.) + 2.*AMPL0;
      AMPL2=AMP2B*(cos(pi*((t1-1500.)/tscale2 - 1.)) + 1.);
      xscale=xscale0;
   end
   
   distc=0.8;
   AMPL=AMPL/pi*xscale;
   ZTOP=zp(nz+1)/zscale1;
   XCEN=.5*xp(nx+1);
   nxmid=nx/2+1;
   X0=(xp(nx+1)-xscale)/2.; % left edge of the updraft plume
   X1=(xp(nx+1)-xscale1-xscale0*distc)/2.;
   
   ft=0; % first time checker
   for i=1:nxmid
      for k=1:nz+1
         ZZ1=zp(k)/zscale1;
         ZZ2=zp(k)/zscale2;
         XL=abs(xp(i)-XCEN); % distance from the center
         XX=XL/(xscale*0.5); % XL scaled by half plume width
         XX1=XL/((xscale1+xscale0)*0.5);
         ZL=2.*zscale1;
         phi(i,k)=0.;
         
         if xp(i)>=zer0*mx+xdisp
            
            % check if this is the first time the program enters "else"
            % do this for the entire column
            % might not be compatible with parallel computing
            if ft==0 
               ydisp=(xp(i)-xdisp).^2.*cos((xp(i)-xdisp)/mx)/my;
               if k==nz+1
                  ft=1;
               end
            end
            if ZZ1<1 % below altitude @ the peak velocity   
               phi(i,k)=((xp(i)-xdisp).^2.*...
                  cos((xp(i)-xdisp)/mx)/my-1-ydisp)*sin(pi*zp(k)/ZL);
            elseif ZZ1>=1 && ZZ2<=1 % between peak vel and top
               ZL=2.*(zscale2-zscale1);
               phi(i,k)=((xp(i)-xdisp).^2.*...
                  cos((xp(i)-xdisp)/mx)/my-1-ydisp)*...
                  sin(pi*(.5+(zp(k)-zscale1)/ZL));
            end
            
         else
            if ZZ1<1
               phi(i,k)=-sin(pi*zp(k)/ZL);
            elseif ZZ1>=1 && ZZ2<1
               ZL=2.*(zscale2-zscale1);
               phi(i,k)=-sin(pi*(.5+(zp(k)-zscale1)/ZL));
            end
         end
         
      end
   end

   for k=1:nz+1
      yscale=1/(1+phi(nxmid,k));
      phi(1:nxmid,k)=(phi(1:nxmid,k)+1)*yscale-1;
   end
   
   phi=phi*AMPL;
   
%    figure('Position',[1722 557 560 420]); plot(xp,phi(:,68));

%    xlim([3000 4200])
%    ylim([-1.2 -0.8])
%    figure('Position',[208 273 560 420]); 
%    figure; plot(xp,-exp(-((xp-X1)/xscale1).^2/g_wid))
   
   for i=nxmid:nx+1
      for k=1:nz+1
         phi(i,k)=-phi(nx+1-i+1,k);
      end
   end
   
   for k=1:nz+1
      zsh=zp(k)/zscale2;
      for i=1:nx+1
         phi(i,k)=phi(i,k) - AMPL2*.5*zsh^2.;
      end
   end
   
   for i=1:nx+1
      for k=1:nz
         ux(i,k)=-(phi(i,k+1)-phi(i,k))/dzp(k)*dt/dxp(i);
      end
   end
   
   for k=1:nz+1
      for i=1:nx
         uz(i,k)=(phi(i+1,k)-phi(i,k))/dxp(i)*dt/dzp(k);
      end
   end
   
   for i=1:nx
      for k=1:nz
         vv(k,i)=0.5*(ux(i,k)+ux(i+1,k))/dt*dxp(i)/rho(k);
         ww(k,i)=0.5*(uz(i,k)+uz(i,k+1))/dt*dzp(k)/rho(k);
      end
   end
   
%    contourf(xp,zp,phi')
%    set(gca,'YDir','normal')
%    colorbar
%    
   figure('Position',[1722 57 560 420]); 
   imagesc(xp,zp,ww*100)
   set(gca,'YDir','normal')
   colorbar
end

%%
% close all

x=0:50:4500;
ft=0;
for ix=length(x):-1:1
   if x(ix)>=zer0*mx+xdisp
      y(ix)=(x(ix)-xdisp).^2.*cos((x(ix)-xdisp)/mx)/my;
   else
      % check if this is the first time the program enters "else"
      % not compatible with parallel computing
      if ft==0 
         ydisp=y(ix+1);
         ft=1;
      end
      y(ix)=ydisp;
   end
end

% y=(y-ydisp)*(max(y)-min(y))/(max(y)-ydisp-min(y))-1;

plot(x,y)
% ylim([-1 0])
% plot(x,); hold off