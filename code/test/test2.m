clear;
close all

load('../csi_log/yanbo/test/test_16.mat');
% load('data/csi_pl.mat');

csi_sample1 = [csi_11(1,edge(1):edge(2));csi_33(1,edge(1):edge(2))];
% csi_sample2 = [csi_11(1,edge(3):edge(4));csi_33(1,edge(3):edge(4))];
% csi_sample3 = [csi_11(1,edge(5):edge(6));csi_33(1,edge(5):edge(6))];

% csi_sample = csi_sample1(1,:);
csi_sample = movmean(csi_sample1(1,:),10);

subplot(2,1,1)
% csi_ph = angle(csi_sample1(1,:));
csi_ph_avg = angle(csi_sample);
% plot(csi_ph,'k.-');hold on
plot(csi_ph_avg,'b.-');hold off
ylabel('phase');xlabel('packet index');
subplot(2,1,2)
% csi_amp = abs(csi_sample1(1,:));
csi_amp_avg = abs(csi_sample);
% plot(csi_amp,'k.-');hold on
plot(csi_amp_avg,'b.-');hold off
ylabel('amplitude');xlabel('packet index');

% %% decide static path (circle fitting)
% win_len = 20; % initialize window length
% sample = csi_sample;
% sample_len = length(sample);
% circ_cent = zeros(2,sample_len);
% sample_fit = cell(sample_len,1);
% 
% % windowing method 1: Rotating
% for i = 1:1:(sample_len-win_len+1)
%     for ii = (i+win_len-1):2:sample_len
%         sample_windowed = sample(i:ii);
%         
%         % compute fSNR
%         [x_cent,y_cent,R,N] = circfit_2(sample_windowed);
%         N_avg = mean(N);
%         
%         % compute phase rotation (relative to the circle center)
%         phase_rotation = phase_accumulate(x_cent,y_cent,sample_windowed);
%         
% %         % plot the samples on IQ domain
% %         x = real(sample_windowed);y = imag(sample_windowed);
% %         plot(x,y,'k.'); hold on
% %         plot(x_cent,y_cent,'ro'); hold off
% % %         xlim([-5 5]);ylim([-5 5]);
% %         title(['Normed noise: ', num2str(N_avg),'Angle: ',num2str(phase_rotation)]);
% %         waitforbuttonpress();
%         
%         if N_avg < 0.03
%             if phase_rotation > pi
%                 circ_cent(1,i) = x_cent;
%                 circ_cent(2,i) = y_cent;
%                 sample_fit{i,1} = sample_windowed;
%                 break;
%             end
%         end
%     end
%     disp(i)
% end
% 
% head = 1;
% % % windowing method 2: Jumping
% % head = 1;
% % while head<=sample_len
% %     for tail = (head+win_len-1):2:sample_len
% %         sample_windowed = sample(head:tail);
% %         
% %         % compute fSNR
% %         [x_cent,y_cent,R,N] = circfit_2(sample_windowed);
% %         N_avg = mean(N);
% %         
% %         % plot the samples on IQ domain
% %         x = real(sample_windowed);y = imag(sample_windowed);
% %         plot(x,y,'k.');hold on
% %         plot(x_cent,y_cent,'ro');hold off
% %         
% %         % compute phase rotation (relative to the circle center)
% %         phase_rotation = phase_accumulate(x_cent,y_cent,sample_windowed);
% %         angle = 360*phase_rotation/(2*pi);
% %         title(['head: ', num2str(head),'Normed noise: ', num2str(N_avg),' Rotation:',num2str(angle)]);
% %         waitforbuttonpress();
% %         
% %         if N_avg >= 0.03
% %             head = tail;
% %             break;
% %         end
% %     end
% % end
% %% extract reflected path
% 
% %% compute distance