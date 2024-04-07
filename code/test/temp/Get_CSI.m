function collect_csi

clear all;

cleanupObj = onCleanup(@cleanMeUp);

addpath('../../function/msocket_func/');

server_sock 	= mslisten(6767);
sock_vec_in     = zeros(1,1,'int32');

sock_vec_in(1,1)= server_sock;

sock_cnt_in    = length(sock_vec_in);
sock_max    = max(sock_vec_in);
sock_min    = min(sock_vec_in);
car_num = 56;

index = 0;
total = 0;
FILL_FLAG = 0;
csi_cnt = 0;
edge_count = 0;

PLOT = 0;
n_sample_file = 1000;

CSI_mat = zeros(3,2,56,1);
count = 0;

while 1
    tic
    
    [sock_vec_out,sock_cnt_out,CSI_struct] = msCSI_server_tmp(sock_cnt_in,sock_vec_in,sock_min,sock_max,2);
    if (length(sock_vec_in) > 1)                        % we connect with at least 1 client
        if (length(CSI_struct) >= 1)                     % the output CSI structure must not be empty
            for csi_st_idx = 1:1:length(CSI_struct)     % all the structure
                CSI_entry   = CSI_struct(1,csi_st_idx);
                N_tx        = CSI_entry.nc;
                N_rx        = CSI_entry.nr;
                num_tones   = CSI_entry.num_tones;
                pay_len     = CSI_entry.payload_len;
%               
%                 if N_rx < 3  || num_tones~= car_num
%                     continue;
%                 end
%               
%                 if N_tx < 3  || num_tones~= car_num
%                     continue;
%                 end
              
%                 if CSI_struct.MAC_idx ~= 14562
%                     continue;
%                 end
                
                if CSI_struct.noise ~= 0
                    continue;
                end

                if isempty(CSI_struct.csi) == 1
                    continue;
                end
                
                count = count + 1;
                CSI_mat(:,:,:,count) = CSI_struct.csi;
                
                total = total + 1
                
                if mod(total, n_sample_file) == 0 
                    save('CSI_atheros_CH149_patchAnt_face.mat','CSI_mat');
                    cleanMeUp();
                    break;
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
    
    toc
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


