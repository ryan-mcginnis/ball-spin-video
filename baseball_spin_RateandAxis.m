function baseball_spin_RateandAxis
%Function to calculate spin axis and rate of a pitched baseball
%Requires tracking of individual markers on the ball, steps are as follows

%Procedure
%1. Establish ball-fixed reference frame, origin at center of ball image
%2. Digitize points on ball and extract position components in plane of
%   image, scale to actual units (radius of ball r = 0.036m)
%3. Calculate remaining position component via x^2 + y^2 + z^2 = r^2
%4. Determine spin axis (T) via SVD:
%5. Calculate spin rate via V = cross(w*T,P) where
%6. Define orientation of ball Z axis
%7. Calculate angle between ball Z axis and rotation axis
%8. Define position of ball in video frame at release as (x,z) of first frame 

%   V is velocity in moving ball ref frame (dP/dt)
%   T is the spin axis
%   P is the position of each marker
%   w is the (scalar) spin rate 
%   for all points in the trial, w = cross(T,P) \ V

%Digitize Marker Position from Ball Video
gui_hand = ball_marker_digitizationGUI;
uiwait(gui_hand);
data = guidata(gui_hand);
close(gui_hand);

%Extract position, velocity, and position plane data
P = [];
V = [];
dP = [];
for j=1:4
    filestr = sprintf('marker%udata',j);
    if ~isempty(data.(filestr));
        t = data.(filestr)(:,1);
        m = data.(filestr)(:,2:4);
        
%         dP = [dP; m - (m(:,1).^0) * mean(m,1)];
        dP = [dP; diff(m,1,1)]; %change in marker position from frame to frame
        V = [V; [diff(m(:,1))./diff(t), diff(m(:,2))./diff(t), diff(m(:,3))./diff(t)]];
        P = [P; m(1:end-1,:)];
    end
end

if isempty(P)
    error('No points selected!');
end

%4. Determine spin axis (SVD)
[~,~,EV] = svd(dP,'econ'); %Columns of EV are eigenvectors
spin_axis = EV(:,3); 


%5. Determine spin rate
wxr = cross((P(:,1).^0)*spin_axis.',P);
spin_rate = ([wxr(:,1); wxr(:,2); wxr(:,3)]  \ [V(:,1); V(:,2); V(:,3)]) * 180/pi; %deg/s

if spin_rate < 0
    spin_axis = -spin_axis;
    spin_rate = abs(spin_rate);
end


%Decompose spin axis into elevation and azimuthal angles
%elevation = angle between T and horiz. plane
%azimuthal = angle between +x-axis and projection of T on horiz. plane
elev = 90 - acosd(dot(spin_axis, [0; 0; 1]));
azi = atan2d(spin_axis(2),spin_axis(1)); 


%Print results to command window
fprintf('Spin Rate: %3.3g deg/s\nSpin Axis: [%3.3g, %3.3g, %3.3g]\n',[spin_rate, spin_axis.']); 
fprintf('Azimuthal: %3.3g deg\nElevation: %3.3g deg\n\n',[azi, elev]); 


%6. Define ball Z axis orientation during trial
p1 = data.marker1data(:,2:4)/data.ballradius;
p2 = data.marker2data(:,2:4)/data.ballradius;
ballZaxis=cross(p1,p2); Znorm = sqrt(sum(ballZaxis.^2,2));
ballZaxis = [ballZaxis(:,1)./Znorm, ballZaxis(:,2)./Znorm, ballZaxis(:,3)./Znorm];


%7. Calculate angle between Z axis and spin axis
SeamStabilityAngle = acosd(dot((ballZaxis(:,1).^0)*spin_axis.',ballZaxis,2));
ind = SeamStabilityAngle > 90; %Why shouldn't this be greater than 90?
SeamStabilityAngle(ind) = 180-SeamStabilityAngle(ind);


%8. Calculate ball position at release
release_pos = data.ballcenterdata(1,:);
release_rad = data.ballradiusdata(1,:); %for conversion from px -> m


%Plot Results
[X,Y,Z] = sphere; Colors = {'r','g','b','k'};
spin_axisP = [spin_axis(1:2); 0]./norm([spin_axis(1:2); 0]);

figure;
hold on; grid on; axis equal; view([0,-1,0]);
surf(X,Y,Z,'facealpha',0.10,'edgealpha',0.10,'facecolor',[0.5,0.5,0.5],'edgecolor',[0.5,0.5,0.5]);
quiver3(-1.25*spin_axis(1),-1.25*spin_axis(2),-1.25*spin_axis(3),2.75*spin_axis(1),2.75*spin_axis(2),2.75*spin_axis(3),'r','linewidth',2);
plot3([0,spin_axisP(1)],[0,spin_axisP(2)],[0,spin_axisP(3)],'-m');
quiver3(0,0,0,0,1.5,0,'k','linewidth',2);
quiver3(0,0,0,1.5,0,0,'k','linewidth',2);
quiver3(0,0,0,0,0,1.5,'k','linewidth',2);
for j=1:4
    filestr = sprintf('marker%udata',j);
    if ~isempty(data.(filestr));
        m = data.(filestr)(:,2:4)/data.ballradius;
        plot3(m(:,1),m(:,2),m(:,3),'.-','color',Colors{j});
    end
end
for j=1:length(ballZaxis)
    plot3([0,ballZaxis(j,1)],[0,ballZaxis(j,2)],[0,ballZaxis(j,3)],'-k');
end
ylabel('Pitch Direction'); zlabel('Vertical'); xlabel('Horizontal');


%Save workspace as a mat file to use for processing later
[filename,filepath] = uiputfile('*.mat','Save processed data as...');
save(strcat(filepath,filename));


end