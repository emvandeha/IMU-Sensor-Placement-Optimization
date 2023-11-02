clear f

for foot = 1:2
    f = insfilterMARG;

    if foot ==1
        acc = data.acc.L_lower_leg;
        gyro = data.gyr.L_lower_leg;
    elseif foot ==2
        acc = data.acc.R_lower_leg;
        gyro = data.gyr.R_lower_leg;
    end

    initstate =...
        [
        0.5251
        0.0513
        0.0147
        0.8493
        2.5541
        5.4406
        0.7544
        0
        0
        0
        0.0003
        0.0003
        0.0003
        0.0012
        0.0012
        0.0012
        19.5281
        -5.0741
        48.0067
        100.0000
        100.0000
        100.0000
        ];

    f.IMUSampleRate = FR;
    f.ReferenceLocation = [0 0 0]; %refloc;
    f.AccelerometerBiasNoise = 2e-4;
    f.AccelerometerNoise = 2;
    f.GyroscopeBiasNoise = 1e-16;
    f.GyroscopeNoise = 1e-5;
    f.MagnetometerBiasNoise = 1e-10;
    f.GeomagneticVectorNoise = 1e-12;
    f.StateCovariance = 1e-9*ones(22);
    f.State = initstate;

    gpsidx = 1;
    N = size(acc,1);%size(accel,1);
    p = zeros(N,3);
    q = zeros(N,1,'quaternion');

    for ii = 1:3237%size(acc,1) %size(accel,1)               % Fuse IMU
        f.predict(acc(ii,:), gyro(ii,:));

        % if ~mod(ii,fix(imuFs/2))            % Fuse magnetometer at 1/2 the IMU rate
        %     f.fusemag(mag(ii,:),Rmag);
        % end
        %
        % if ~mod(ii,imuFs)                   % Fuse GPS once per second
        %     f.fusegps(lla(gpsidx,:),Rpos,gpsvel(gpsidx,:),Rvel);
        %     gpsidx = gpsidx + 1;
        % end

        [p(ii,:),q(ii)] = pose(f);           %Log estimated pose
    end
    foot_position(foot,:,:) = p;
end 

for ii = 1:length(foot_position)
    foot = 1;
    plot(squeeze(foot_position(foot,ii,1)),squeeze(foot_position(foot,ii,2)),'*')
    hold on 
    foot = 2;
    plot(squeeze(foot_position(foot,ii,1)),squeeze(foot_position(foot,ii,2)),'*')
    shg
end
    