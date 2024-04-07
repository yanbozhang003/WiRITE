function collect_csi

clear all;
 
cleanupObj = onCleanup(@cleanMeUp);  

addpath('../msocket');

server_sock 	= mslisten(6666);
sock_vec_in     = zeros(1,1,'int32');

sock_vec_in(1,1)= server_sock;

sock_cnt_in    = length(sock_vec_in);
sock_max    = max(sock_vec_in); 
sock_min    = min(sock_vec_in);
car_num = 56;

index = 0;
plt_flg = 0;
flg_cnt = 0;
plt_cnt = 0;
csi_11 = [];
while 1     
    [sock_vec_out,sock_cnt_out,CSI_struct] = msCSI_server_tmp(sock_cnt_in,sock_vec_in,sock_min,sock_max,2); 
    if (length(sock_vec_in) > 1)                        % we connect with at least 1 client
        if (length(CSI_struct) >= 1)                     % the output CSI structure must not be empty
            for csi_st_idx = 1:1:length(CSI_struct)     % all the structure
                CSI_entry   = CSI_struct(1,csi_st_idx);
                N_tx        = CSI_entry.nc;
                N_rx        = CSI_entry.nr;    
                num_tones   = CSI_entry.num_tones;
%               
                if N_rx < 2  || num_tones~= car_num
                    continue;
                end
              
                if N_tx < 2  || num_tones~= car_num
                    continue;
                end
              
%                 if CSI_struct.MAC_idx ~= 37845
%                     continue;
%                 end
                
%                 if CSI_struct.phyerr ~= 0
%                     continue;
%                 end

%                 if isempty(CSI_struct.csi) == 1
%                     continue;
%                 end
                
                index = index + 1;
                index
                
                paylen = CSI_entry.payload_len;
                if paylen~=120
                    flg_cnt = flg_cnt+1;
                    if mod(flg_cnt,2)==1
                        plt_flg=1;
                    else
                        continue
                    end
                end
                
                plt_cnt = plt_cnt+1;
                csi = CSI_entry.csi;
                csi_11 = [csi_11 mean(csi(1,1,:)./csi(1,2,:))];
                csi_ph = angle(csi_11);
                    
                if plt_flg == 1
                    plot(1:1:plt_cnt,csi_ph,'k.-');
                    drawnow
                end
            end
        end
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%            adjust the sockets 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sock_cnt_in     = sock_cnt_out;
    sock_vec_in     = sock_vec_out;
    sock_max        = max(sock_vec_in);
    sock_min        = min(sock_vec_in);    
    
end

    
function cleanMeUp()
    
    for i = 1:1:length(sock_vec_out)
        fprintf('close all active socket and exit!!\n');
        msclose(sock_vec_out(i,1));
    end
    close all;
    clear all;
end

end
