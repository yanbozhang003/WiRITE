% clear;
% close all
% 
% x = -8:1:8;
% y = -8:1:8;
% 
% dot_x = -8:1:8;
% dot_y = ones(length(dot_x))+1;
% 
% line_x = [-8 0];
% line_y = [2 0];
% plot(dot_x, dot_y, 'k.','MarkerSize',15);hold on
% 
% for i = -8:1:8
%     line_x = [i 0]; line_y = [2 0];
%     plot(line_x,line_y,'k:'); hold on
% end
% xlim([-8 8]); ylim([-8 8]);
% xlabel('I'); ylabel('Q');

figure
plot((1:10).^2)
f = 70;
c = (f-32)/1.8;
b = 'd';
title(sprintf('Category: %s  Accuracy: %.2f', b, f));