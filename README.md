# o3de-docker
O3DE simulation for Husarion robots.

## ROSbot XL mapping demo

Execution: 
```bash
xhost +local:docker
docker compose -f compose.sim.o3de.yaml up
```

Wait for the O3DE to load, then open `DemoLevel` and click the Play button (in the upper right corner) to start the simulation. Now you can use arrow keys to control the robot.