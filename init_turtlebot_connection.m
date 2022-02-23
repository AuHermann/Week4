
function [] = init_turtlebot_connection(turtlebot_ip, host_ip)
    turtlebot_uri =  strcat('http://',turtlebot_ip,':11311');
    %Turtlebot ip
    setenv('ROS_MASTER_URI',turtlebot_uri);
    %Your own ip
    setenv('ROS_IP', host_ip);

    rosinit(turtlebot_uri, 'NodeHost',host_ip);
end