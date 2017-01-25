function dirsize=directory_size(rootdir)

info=dir(rootdir);
len=length(info);
dirsize=0;

for i=3:len
    tmp=getfield(info(i),'bytes') ;
   if(getfield(info(i),'isdir'))
        tmp=directory_size([rootdir,'\',getfield(info(i),'name')]);
   end
   dirsize=dirsize+tmp;
end


