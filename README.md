# o3de-docker
O3DE simulation for Husarion robots

Execution: 
```bash
xhost +local:docker
docker compose -f compose.sim.o3de.yaml up
```

In a new terminal:
```bash
docker exec -it o3de_rosbot_xl bash
. /opt/ros/humble/setup.bash
/data/workspace/WarehouseTest/build/linux/bin/profile/Editor
```

To run navigation demo, in a seperate terminal execute:
```bash
docker exec -it o3de_rosbot_xl bash
. /opt/ros/humble/setup.bash
ros2 launch /data/workspace/WarehouseTest/Examples/slam_navigation/launch/navigation.launch.py
```