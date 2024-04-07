clear;
close all

load('csi_fit.mat');

tmp = find(circ_cent(1,:)==0);
sample_len = tmp(1);

% for i = 1:1:sample_len
%     circ = sample_fit{i};
%     
%     x = real(circ); y = imag(circ);
%     plot(x,y,'k.-');
%     drawnow
%     
% 	disp(i)
% end

%% extract dynamic component
circ_cent = circ_cent(:,1:(sample_len-1));
csi_sample = csi_sample(1,1:(sample_len-1));
a = 1;
static_component = complex(circ_cent(1,:),circ_cent(2,:));
dynamic_component = csi_sample - static_component;
%% compute distance
dyn_comp_angle = unwrap(angle(dynamic_component));
% dyn_comp_amp = abs(dynamic_component);
% subplot(2,1,1)
% plot(dyn_comp_amp,'k.-');
% title('amplitude');
% subplot(2,1,2)
% plot(dyn_comp_angle,'k.-');
% title('angle');

% x = real(dynamic_component); y = imag(dynamic_component);
% plot(x,y,'k.');

light_speed = 3*10^8;
distance = abs(dyn_comp_angle) / (2*pi*5.8*10^9)*light_speed;
distance = distance * 100; % m->cm

subplot(2,1,1)
plot(dyn_comp_angle,'k.-');
xlabel('Packet Index');
ylabel('DC unwrapped Phase (radian)');
grid minor
subplot(2,1,2)
plot(distance,'k.-');
xlabel('Packet Index');
ylabel('Distance (cm)');
grid minor




