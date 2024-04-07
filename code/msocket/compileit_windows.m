% Note: this only works in windows
% Run mex -setup first, and select the C compiler to
% be the Microsoft compiler

% This needs to be changed to the approproate directory
libdir = ...
    'C:\Program Files\MATLAB\R2020b\sys\lcc64\lcc64\lib64'
% 'C:/Program Files/MATLAB/R2015b/sys/lcc/lib'

files = {'msconnect.c',...
  'msaccept.c',...
  'mslisten.c',...
  'msclose.c',...
  'mssendraw.c',...
  'msrecvraw.c'  
  };

% Create libraries for above files
for i1=1:length(files)
  cmd=sprintf('mex -I. -DWIN32 "-L%s" -lws2_32.lib  %s',...
    libdir,files{i1});
  cmd
  eval(cmd);
end

% Compile object code
mex -I. -DWIN32 -c matvar.cpp
mex -I. -DWIN32 -c msrecv.cpp
mex -I. -DWIN32 -c mssend.cpp
mex -I. -DWIN32 -c msCSI_recv.cpp
mex -I. -DWIN32 -c msCSI_server.cpp
mex -I. -DWIN32 -c msCSI_server_tmp.cpp

cmd = sprintf('mex -I. -DWIN32 "-L%s" -lws2_32.lib msrecv.obj matvar.obj', libdir);
cmd
eval(cmd);


cmd = sprintf('mex -I. -DWIN32 mssend.obj matvar.obj -lws2_32.lib -L"%s"',libdir);
cmd
eval(cmd);

cmd = sprintf('mex -I. -DWIN32 msCSI_recv.obj matvar.obj -lws2_32.lib -L"%s"',libdir);
cmd
eval(cmd);


cmd = sprintf('mex -I. -DWIN32 msCSI_server.obj matvar.obj -lws2_32.lib -L"%s"',libdir);
cmd

cmd = sprintf('mex -I. -DWIN32 msCSI_server_tmp.obj matvar.obj -lws2_32.lib -L"%s"',libdir);
cmd

eval(cmd);
system('del *.obj');
system('move *.mexw32 ..');


