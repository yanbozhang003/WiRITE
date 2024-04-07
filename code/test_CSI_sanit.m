function collect_csi

clear all;

cleanupObj = onCleanup(@cleanMeUp);

%% add socket config

addpath('function/msocket_func');

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

digit = {'0','1','2','3','4','5','6','7','8','9'};
letter = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','d','e','f','g','h','n','q','r','t'};
% chinese = {'½Ì','½Ò','½Ú','½á','½í','½ñ','¾®','¾Ã','¾Å','¿ª','¿Ú','¿÷','Á¦','ÁË','Âí','Ã´','ÃÅ','Ä¾','ÄË','Å£','Å®','Æ¬','Æß','Æò','Æø','Ç§','Ç·','È®','ÈÐ','ÈÕ','É½','ÉÏ','É×','Éý','Ê¬','Ê¿','ÊÏ','ÊÖ','Ë®','ÍÁ','ÍÍ','Íè','Íò','Íõ','Íö','Îª','ÎÄ','ÎÚ','ÎÞ','Îå','Îç','Ï¦','Ï°','ÏÂ','Ïç','Ð¡','ÐÄ','ÑÀ','Ò²','ÒÑ','ÒÚ','Òå','Ó¦','Óµ','Ó½','ÓÀ','ÓÒ','ÓÕ','ÓÚ','ÓÜ','Óå','Óæ','Óë','Óì','Óñ','Ô¦','ÔÂ','ÔÐ','ÔÑ','ÔÙ','ÔÝ','ÔÞ','Õ§','ÕÉ','ÕÌ','ÕÔ','Õè','Õê','Õù','Õý','Ö§','Öª','Ö¬','Ö®','Ö¹','ÖÐ','Öá','Öþ','×¦','×¨','×Ð','×Ó','°¬','°Å','°Ë','°Í','°Ô','°ã','°é','°ò','±´','±¹','±À','±Ô','±Û','±ê','²»','²Å','²Í','²æ','³¤','³µ','³Á','³Ç','³Ô','³Ù','³ó','³ô','³ý','´¨','´¸','´ç','´é','´ó','µ¤','µ¶','µ¾','µÄ','µÎ','µÝ','¶·','¶Á','¶Ã','¶Ú','¶ë','¶ò','¶ù','¶û','·¦','·²','·´','·Â','·É','·á','·ê','·ò','·ú','·û','·þ','¸²','¸¸','¸É','¸â','¸ê','¸ö','¹¤','¹­','¹®','¹¯','¹µ','¹Ì','¹Ò','¹ã','¹õ','º­','º®','ºº','ºÃ','ºÄ','ºÓ','ºÝ','ºè','»¥','»§','»°','»µ','»Î','»å','¼ª','¼°','¼¶','¼¸','¼º','¼Ó','¼Ö','¼Ù','¼û','¼ü','½­','½²'};

classNames = digit;   % chinese is not ready

if isequal(classNames, digit)
    modelfile = './ml_model/digit-raw.h5';
    img_size = 28;
elseif isequal(classNames, letter)
    modelfile = './ml_model/letter-raw.h5';
    img_size = 28;
else
    modelfile = './ml_model/chinese-raw.h5';
    img_size = 64;
%     img_size = 28;
end
net = importKerasNetwork(modelfile, 'Classes', classNames);

img_dir = './image/';

PLOT = 0;
% n_sample_file = 50000;
n_sample_file = 200;

while 1
    [sock_vec_out,sock_cnt_out,CSI_struct] = msCSI_server_tmp(sock_cnt_in,sock_vec_in,sock_min,sock_max,2);
    if (length(sock_vec_in) > 1)                        % we connect with at least 1 client
        if (length(CSI_struct) >= 1)                     % the output CSI structure must not be empty
            for csi_st_idx = 1:1:length(CSI_struct)     % all the structure
                CSI_entry   = CSI_struct(1,csi_st_idx);
                N_tx        = CSI_entry.nc;
                N_rx        = CSI_entry.nr;
                num_tones   = CSI_entry.num_tones;
                pay_len     = CSI_entry.payload_len;
                
                if N_rx < 3  || num_tones~= car_num
                    continue;
                end
              
                if N_tx < 3  || num_tones~= car_num
                    continue;
                end
              
                if CSI_struct.MAC_idx ~= 14562
                    continue;
                end
                
                if CSI_struct.phyerr ~= 0
                    continue;
                end

                if isempty(CSI_struct.csi) == 1
                    continue;
                end
                
                if pay_len ~= 120
                    edge_count = edge_count+1;
                    if mod(edge_count,2)==1
                        FILL_FLAG = 1;
                    elseif mod(edge_count,2)==0
                        FILL_FLAG = 0;
                    end
                end
                
                if FILL_FLAG == 1
                    close all
                    % start filling CSI_st_all
                    csi_cnt = csi_cnt + 1;
                    CSI_st_all(csi_cnt) = CSI_entry;
                elseif FILL_FLAG == 0
                    if csi_cnt ~= 0
                     %% csi sanit
                        csi_cnt  = 0;
                        csi_11 = zeros(1,1); csi_33 = zeros(1,1); edge = zeros(1,1);
                        edge_cnt = 2; edge(1) = 1; edge(2) = length(CSI_st_all);
                        for pkt_idx = 1:1:length(CSI_st_all)
                            csi = CSI_st_all(1,pkt_idx).csi;
                            
                            csi_cnt = csi_cnt + 1
                            csi_11(csi_cnt) = mean(csi(1,1,:)./csi(1,2,:));
                            csi_33(csi_cnt) = mean(csi(3,3,:)./csi(3,2,:));
                        end
                        
                        
                    end
                end
                
                total = total + 1
                if total > n_sample_file
                    break
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