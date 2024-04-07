clear;
close all

load('test_traj2.mat');

cent_left = [0 0];
cent_right = [41 0];

plot(cent_left(1),cent_left(2),'k.','MarkerSize',20);hold on
plot(cent_right(1),cent_right(2),'k.','MarkerSize',20);hold on

% for i = 1:1:length(int_x)    
    plot(int_x, int_y, 'r.','MarkerSize',20);hold off
%     drawnow
% end