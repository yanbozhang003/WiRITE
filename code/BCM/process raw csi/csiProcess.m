clear all
%% csireader.m
%
% read and plot CSI from UDPs created using the nexmon CSI extractor (nexmon.org/csi)
% modify the configuration section to your needs
% make sure you run >mex unpack_float.c before reading values from bcm4358 or bcm4366c0 for the first time
%
% the example.pcap file contains 4(core 0-1, nss 0-1) packets captured on a bcm4358
%

%% configuration
CHIP = '4366c0';          % wifi chip (possible values 4339, 4358, 43455c0, 4366c0)
BW = 80;                % bandwidth
rx_config = [0 1];        % rx radio chain, the 2nd antenna is embedded inside, we dont use that
tx_config = [0 1 2];      % 3 spatial streams

fileName = 'bcm_write_test1';
FILE = ['../data/raw/',fileName,'.pcap'];% capture file
NPKTS_MAX = 100000;       % max number of UDPs to process

%% read file
HOFFSET = 16;           % header offset
NFFT = BW*3.2;          % fft size
p = readpcap();
p.open(FILE);
n = min(length(p.all()),NPKTS_MAX);
p.from_start();
csi_buff = complex(zeros(n,NFFT),0);
k = 1;

core_v = zeros(1,1);
rxss_v = zeros(1,1);
pkt_v = zeros(1,1);

CSI = zeros(length(rx_config),length(tx_config),256,1); % (rxAnt, txAnt, subc, pkt), current only support tx=1
csi_tmp = zeros(length(rx_config), length(tx_config), 256);
pkt_cnt = 0;
while (k <= n)
    f = p.next();
    if isempty(f)
        disp('no more frames');
        break;
    end
    if f.header.orig_len-(HOFFSET-1)*4 ~= NFFT*4
        disp('skipped frame with incorrect size');
        continue;
    end
    
    payload = f.payload;
    payloadbytes = typecast(payload,'uint8');
    core = bitand(payloadbytes(56),3);
    rxss = bitand(bitshift(payloadbytes(56),-3),3);
    pkt = payloadbytes(53); % although the number should divided by 16
    
    core_v(k,1) = core;
    rxss_v(k,1) = rxss;
    pkt_v(k,1) = pkt;
    fprintf('core : %d | rxss: %d | pkt: %d\n', core, rxss, pkt);
    
    H = payload(HOFFSET:HOFFSET+NFFT-1);
    if (strcmp(CHIP,'4339') || strcmp(CHIP,'43455c0'))
        Hout = typecast(H, 'int16');
    elseif (strcmp(CHIP,'4358'))
        Hout = unpack_float(int32(0), int32(NFFT), H);
    elseif (strcmp(CHIP,'4366c0'))
        Hout = unpack_float(int32(1), int32(NFFT), H);
    else
        disp('invalid CHIP');
        break;
    end
    Hout = reshape(Hout,2,[]).';
    cmplx = double(Hout(1:NFFT,1))+1j*double(Hout(1:NFFT,2));
    csi_buff(k,:) = cmplx.';
    k = k + 1;   
    
    % reconstruct CSI
    % the core->rx and rxss->tx mapping only applies to WiRITE antenna
    % configuration
    if pkt == 255
        disp('skipped frame with sequence number 255');
        continue
    end
    rx_idx = core + 1;
    tx_idx = rxss + 1;
    
    csi_tmp(rx_idx, tx_idx,:) = cmplx;
    flag1 = length(find(csi_tmp==0));
    
    if flag1<=100
        pkt_cnt = pkt_cnt + 1;
        
        CSI(:,:,:,pkt_cnt) = csi_tmp;
        csi_tmp = zeros(length(rx_config),length(tx_config),256);
    end
end

% select subcarrier in use
head = 3; left_len = 120; tail = 255; right_len = 120;
seg1 = head:head+left_len; seg2 = tail-right_len:tail;
CSI_struct = zeros(length(rx_config),length(tx_config),length([seg1 seg2]),1);  % structure for real CSI
for pkt_idx = 1:1:pkt_cnt
    CSI_mat = squeeze(CSI(:,:,:,pkt_idx));
    if length(rx_config)==1
        CSI_mat = CSI_mat.';
    end
    CSI_mat_tmp = CSI_mat(:,:,[seg2 seg1]);    % Is the left half and right half alternates? (Ask Jakob)
%     CSI_mat_tmp = CSI_mat(:,:,[seg1 seg2]);
    CSI_mat_tmp = flip(CSI_mat_tmp,3);           % flip subcarriers
    CSI_struct(:,:,:,pkt_idx) = CSI_mat_tmp;
end

save(['../data/mat/',fileName,'.mat'],'CSI_struct');

% plotcsi_bw80(csi_buff, NFFT, false, core_v, rxss_v, pkt_v);



