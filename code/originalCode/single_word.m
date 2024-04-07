clear all;
close all;

polar_plot = 0;
% 
type = 1;

if type == 0
    modelfile = 'mnist.h5';
    classNames = {'0','1','2','3','4','5','6','7','8','9'};
    net = importKerasNetwork(modelfile,'Classes',classNames);
elseif type == 1
    modelfile = 'emnist-up-tuned.h5';
    classNames = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
    net = importKerasNetwork(modelfile,'Classes',classNames);
elseif type == 2
    modelfile = 'emnist-low.h5';
    classNames = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
    net = importKerasNetwork(modelfile,'Classes',classNames);
end

lambda = 5.8;
cent_left = [0 0];
cent_right = [41 0];

word = 'D';
tr_num = 1;
samp_idx = 1;
dir_name = ['./csi_log/uppercase/trace', num2str(tr_num), '/sample/sample_', word];

samp = load(dir_name);
edge_idx = find(samp.edge);

if word == 'K' && tr_num ==r 2
    edge_idx(11) = [];
end


for i = 1:2:length(edge_idx)  
    samp_s_idx((i+1)/2) = edge_idx(i);
    samp_e_idx((i+1)/2) = edge_idx(i+1);
    samp_len((i+1)/2) = samp_e_idx((i+1)/2) - samp_s_idx((i+1)/2) + 1;
end

%
csi_left = samp.csi_11(samp_s_idx(samp_idx):samp_e_idx(samp_idx));
csi_right = samp.csi_33(samp_s_idx(samp_idx):samp_e_idx(samp_idx));

[c_left, r_left, end_idx_left, loss_left, f_left] = f_est(csi_left);
[c_right, r_right, end_idx_right, loss_right, f_right] = f_est(csi_right);

of_left = exp(1i*  0.4390);
of_right = exp(1i* 1.7300);

b_min = 20;
b_max = 40;
c = 4;  
a_min = sqrt(c^2 + b_min.^2);
a_max = sqrt(c^2 + b_max.^2);  

for i = 1:length(f_left)
    if f_left(i) ~= inf && f_right(i) ~= inf
        first_idx = i;
        break;
        
    end
end

traj_idx = 1;
a_left_idx = 1;
a_right_idx = 1;
pl_left = 8 - lambda/2 - lambda * angle(f_left(first_idx)/of_left)/(2*pi);

while pl_left < 2 * a_max
    if pl_left > 2 * a_min
        
        a_left(a_left_idx) = pl_left/2;
       
        
        pl_right = 8 - lambda/2 - lambda * angle(f_right(first_idx)/of_right)/(2*pi);
        
        while pl_right < 2 * a_max
            if pl_right > 2 * a_min
            
                a_right(a_right_idx) = pl_right/2;
                
                
                [int_x, int_y] = find_traj(a_left(a_left_idx), a_right(a_right_idx), f_left(first_idx:end), f_right(first_idx:end));
                if isempty(int_x) == 0
                    traj{traj_idx} = [int_x int_y];
                
                    traj_idx = traj_idx + 1;
                end
                pl_right = pl_right + lambda;
                a_right_idx = a_right_idx + 1;
                
            else
                
                pl_right = pl_right + lambda;
            
            end
        end
        pl_left = pl_left + lambda;
        a_left_idx = a_left_idx + 1;

    else
        pl_left = pl_left + lambda;
    end
end
%%
sum_score = zeros(1,length(classNames));

for i = 1:length(traj)
    traj_samp = traj{i};
    img = traj2img(traj_samp*10,3);
    img_center = scale_img(img);
    img_sample = normalize_sample_2d(img_center);
%     img_sample = uint8(img_sample*255);
    [label, score] = classify(net,img_sample);
    sum_score = sum_score + score;
%     entropy = -sum(score.*log2(score));
    est_score(i,:) = score;
    est_label(i) = string(label);
% 
%     plot(traj_samp(:,1), traj_samp(:,2), 'r');
%     hold on;
%     plot(cent_left(1), cent_left(2), 'd', 'MarkerSize', 15, 'Color', 'b');
%     hold on;
%     plot(cent_right(1), cent_right(2), 'd', 'MarkerSize', 15, 'Color', 'b');
%     xlim([-10 50]);
%     ylim([-10 50]);
% %     title([i, score(3)])
%     hold on
% %     waitforbuttonpress
end
%%
% [min_value idx] = min(est_entropy);
[max_v lb_idx] = max(sum_score);
label = string(classNames{lb_idx});
[max_v idx]  = max(est_score(:,lb_idx));
traj_final = traj{round(length(traj)/2)};
plot(traj_final(:,1), traj_final(:,2), 'rx');
title(label)
% 
% for t_i = 1:length(traj)
%     traj_samp = traj{t_i}; 
%     traj_samp(:,1) = movmean(traj_samp(:,1),10);
%     traj_samp(:,2) = movmean(traj_samp(:,2),10);
% 
%     plot(traj_samp(:,1), traj_samp(:,2), 'ro','MarkerSize', 5 ,'MarkerFaceColor','r');
%     title(t_i)
%     axis equal
%     hold off
%     drawnow
%     
%     waitforbuttonpress
% end
% traj_samp = traj{idx};
% traj_samp(:,1) = movmean(traj_samp(:,1),10);
% traj_samp(:,2) = movmean(traj_samp(:,2),10);
% plot(traj_samp(:,1), traj_samp(:,2), 'ro');
%%
img = traj2img(traj_samp*10,5);
[img_center, img_scaled] = scale_img(img);
img_sample = normalize_sample_2d(img_center);
imshow(img_sample)

tiledlayout(3,2) % Requires R2019b or later

nexttile
xlim([min(real(csi_left)) max(real(csi_left))]);
ylim([min(imag(csi_left)) max(imag(csi_left))]);
title('CSI (left link)', 'FontSize', 15)
xlabel('I', 'FontSize', 15, 'FontName', 'Times New Roman') 
ylabel('Q', 'FontSize', 15, 'FontName', 'Times New Roman')
aa = get(gca,'XTickLabel');
set(gca,'XTickLabel',aa,'fontsize',18)
grid on;
hold on;

nexttile
xlim([min(real(csi_right)) max(real(csi_right))]);
ylim([min(imag(csi_right)) max(imag(csi_right))]);
title('CSI (right link)','FontSize', 15)
xlabel('I', 'FontSize', 15, 'FontName', 'Times New Roman') 
ylabel('Q', 'FontSize', 15, 'FontName', 'Times New Roman')
aa = get(gca,'XTickLabel');
set(gca,'XTickLabel',aa,'fontsize',18)
grid on;
hold on;

nexttile([2 2])
plot(cent_left(1), cent_left(2), 'd', 'MarkerSize', 20, 'Color', 'b');
hold on;
plot(cent_right(1), cent_right(2), 'd', 'MarkerSize', 20, 'Color', 'b');
hold on;
min_x = min(traj_samp(:,1)); 
max_x = max(traj_samp(:,1));
min_y = min(traj_samp(:,2)); 
max_y = max(traj_samp(:,2));
x_range = max_x - min_x;
y_range = max_y - min_y;

xlim([min_x - x_range * 1 max_x + x_range * 1]);
ylim([min_y - y_range * 0.2 max_y + y_range * 0.4]);
xlabel('Width (cm)', 'FontSize', 20) 
ylabel('Height (cm)', 'FontSize', 20) 
title('Hand trajactory', 'FontSize', 20)
aa = get(gca,'XTickLabel');
set(gca,'XTickLabel',aa,'fontsize',18)
grid on;
hold on;

cent_left_x = [1/3.85 1/3.85];
cent_left_y = [1.3/8 2/9];

cent_right_x = [1-1/4.73 1-1/4.73 ];
cent_right_y = [1.3/8 2/9];
annotation('textarrow',cent_left_x, cent_left_y,'String','Link 1','FontSize',20)
annotation('textarrow',cent_right_x, cent_right_y,'String','Link 2','FontSize',20)

set(gcf, 'Position',  [500 10 800 1100])


iii = 0;
for ii = 1:length(csi_left)
    if f_left(ii) ~= inf && f_right(ii) ~= inf
        iii = iii + 1;
        nexttile(1)
        plot(csi_left(ii), 'bo-.', 'MarkerSize', 2);
        hold on;
        p11 = plot(csi_left(ii), 'ro', 'MarkerSize', 10, 'MarkerFaceColor','r');
        hold on;
        
        nexttile(2)
        if iii > 1
            delete(p22);
        end
        plot(csi_right(ii), 'bo-.', 'MarkerSize', 2);
        hold on;
        p22 = plot(csi_right(ii), 'ro', 'MarkerSize', 10, 'MarkerFaceColor','r');
        hold on;
        
        
        nexttile(3)
        
        plot(traj_samp(iii,1), traj_samp(iii,2), 'ko','MarkerSize', 8,'MarkerFaceColor','k');
        hold on;
        p33 = plot(traj_samp(iii,1), traj_samp(iii,2), 'ro','MarkerSize', 15,'MarkerFaceColor','r');
        hold on;
        drawnow
%         pause(0.001)
        
        
        delete(p11);
        delete(p22);
        delete(p33);
    end
end


annotation('textbox',...
    [0.15 0.51 0.28 0.09],...
    'String', ['\color{black}Est result: \color{red}' + label + ...
        ' (prob.: ' + ' ' + num2str(est_score(idx,lb_idx)) + ')'],...
    'FontSize',30,...
    'FontName','Arial',...
    'LineStyle','-',...
    'EdgeColor',[0.1 0.1 0.1],...
    'LineWidth',2,...
    'FitBoxToText', 'on',...
    'BackgroundColor',[0.9 0.9 0.9]);

%%

if polar_plot == 1
    th = linspace(0,2*pi,20)';
    for i = 1:length(csi_left)
        subplot(211)
        plot(csi_left, 'b-.');
        hold on;

        if r_left(i) ~= inf
            x_left = r_left(i)*cos(th)+c_left(i,1); 
            y_left = r_left(i)*sin(th)+c_left(i,2);
            plot(c_left(i,1),c_left(i,2),'ro');
            hold on;
            plot(x_left, y_left, 'r-');
            hold on;
            plot(csi_left(i:end_idx_left(i)), 'bx');

            hold off;
        end
        xlim([min(real(csi_left)) max(real(csi_left))])
        ylim([min(imag(csi_left)) max(imag(csi_left))])
        title(["left" i])


        subplot(212)
        plot(csi_right, 'b-.');
        hold on;

        if r_right(i) ~= inf
            x_right = r_right(i)*cos(th)+c_right(i,1); 
            y_right = r_right(i)*sin(th)+c_right(i,2);
            plot(c_right(i,1),c_right(i,2),'ro');
            hold on;
            plot(x_right, y_right, 'r-');
            hold on;
            plot(csi_right(i:end_idx_right(i)), 'bx');
            hold off;
        end

        xlim([min(real(csi_right)) max(real(csi_right))])
        ylim([min(imag(csi_right)) max(imag(csi_right))])
        title(["right" i])
 
        waitforbuttonpress

    end
end


