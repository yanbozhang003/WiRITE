clear;
close all

% load('./traj_log/uppercase/trace2/B_2.mat');
load('./test_traj_5.mat');
n_sample = length(traj);

cent_left = [0 0];
cent_right = [41 0];

plot(cent_left(1),cent_left(2),'k.','MarkerSize',20);hold on
plot(cent_right(1),cent_right(2),'k.','MarkerSize',20);hold on

for j = 1:1:n_sample
    for i = 1:1:length(traj{1,j})
        x = traj{1,j}{1,i}(:,1);
        y = traj{1,j}{1,i}(:,2);
        plot(x, y, 'r.','MarkerSize',10);
        xlim([0 50]);ylim([0 50]);
        i
        hold off
        waitforbuttonpress();
    end
%     hold off
end