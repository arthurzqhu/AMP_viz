function saveVid(F,filename,framerate)

v=VideoWriter(['vids/' filename],'MPEG-4');
v.FrameRate=framerate;
open(v)
writeVideo(v,F)
close(v)

end