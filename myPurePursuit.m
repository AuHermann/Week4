
function [] = myPurePursuit(path)
    
    sampleTime = 0.1;
    vizRate = rateControl(1/sampleTime);
    robotInitialLocation = path(1,:);
    robotGoal = path(end,:);
    initialOrientation = pi/2;
    robotCurrentPose = [robotInitialLocation initialOrientation]'; 
    robot = differentialDriveKinematics("TrackWidth", 0.3, "VehicleInputs", "VehicleSpeedHeadingRate");
    rospubRest = rospublisher("/mobile_base/commands/reset_odometry","Dataformat", "struct");
    resetMsg = rosmessage(rospubRest);
    send(rospubRest,resetMsg)

    controller = controllerPurePursuit;
    controller.Waypoints = path;    
    controller.DesiredLinearVelocity = 0.4;
    controller.MaxAngularVelocity = 5;
    controller.LookaheadDistance = 1;
    goalRadius = 0.2;
    distanceToGoal = norm(robotInitialLocation - robotGoal);
    
    rospub = rospublisher("/mobile_base/commands/velocity","Dataformat", "struct");
    rossub = rossubscriber("/tf");
    velmsg = rosmessage(rospub);

    figure
    frameSize = robot.TrackWidth;

    
    while( distanceToGoal > goalRadius )
        
        % Compute the controller outputs, i.e., the inputs to the robot
        [v, omega] = controller(robotCurrentPose);
        
        % Get the robot's velocity using controller inputs
        %vel = derivative(robot, robotCurrentPose, [v omega]);
        velmsg.Linear.X = v;
        velmsg.Angular.Z = omega;
        send(rospub, velmsg);
        %pause(0.5)
        %Update the current pose
        %robotCurrentPose = robotCurrentPose + vel*sampleTime; 
        msg3 = receive(rossub,3);
        transform = msg3.Transforms.Transform;
        robotCurrentPose = [transform.Translation.X; transform.Translation.Y; transform.Rotation.Z];
        
        %Re-compute the distance to the goal
        distanceToGoal = norm(robotCurrentPose(1:2) - robotGoal(:));

        hold off
        plot(path(:,1),path(:,2),"k--d")
        hold all
        plotTrVec = [robotCurrentPose(1:2); 0];
        plotRot = axang2quat([0 0 1 robotCurrentPose(3)]);
        plotTransforms(plotTrVec',plotRot,"MeshFilePath","groundvehiclewithload.stl","Parent",gca,"View","2D","FrameSize",frameSize);
        light;
        xlim([-1 10])
        ylim([-4 1])

        waitfor(vizRate);

    end

end