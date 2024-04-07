clear;
close all
addpath('./function/msocket_func/');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   SOCKET  config
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
server_sock = mslisten(6767);
sock_vec_in = zeros(1,1,'int32');
sock_vec_in(1,1) = server_sock;
sock_cnt_in = length(sock_vec_in); 
sock_max = max(sock_vec_in);
sock_min = min(sock_vec_in);

packet_count = 0;

while 1    
    tic
    [sock_vec_out,sock_cnt_out,CSI_struct] = msCSI_server_tmp(sock_cnt_in,sock_vec_in,sock_min,sock_max,2);
    
    if (length(sock_vec_in) > 1)                        % we connect with at least 1 client
        if (length(CSI_struct) >= 1)                     % the output CSI structure must not be empty
            
            packet_count = packet_count+1;
            disp(packet_count);
            
        end
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%            adjust the sockets 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sock_cnt_in     = sock_cnt_out;
    sock_vec_in     = sock_vec_out;
    sock_max        = max(sock_vec_in);
    sock_min        = min(sock_vec_in);    
    toc
end

for i = 1:1:length(sock_vec_out)
    fprintf('close all active socket and exit!!\n');
    msclose(sock_vec_out(i,1));
end