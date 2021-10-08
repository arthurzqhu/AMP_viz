function saveVid(F,filename,framerate)

if strcmp(computer('arch'),'maci64')
   v=VideoWriter(['vids/' filename],'MPEG-4');
elseif strcmp(computer('arch'),'glnxa64')
   v=VideoWriter(['vids/' filename],'Archival');
end

v.FrameRate=framerate;
open(v)
writeVideo(v,F)
close(v)

end
