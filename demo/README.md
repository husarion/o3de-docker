# ROSbot XL mapping demo

For a more detailed description check out [our tutorial](https://husarion.com/tutorials/simulations/o3de-rosbot-xl-slam-toolbox/).

Pulling Docker images:

```bash
docker compose pull
```

Execution: 

```bash
xhost +local:docker
docker compose up
```

Wait for the O3DE to load, then open `DemoLevel` and click the Play button (in the upper right corner) to start the simulation. Now you can use arrow keys to control the robot.
