# kubernetes之探针

探针是`kubelet`用于周期性诊断容器的一种方式。目前`kubenertes`提供两种探针，通过调用容器提供的句柄(`handler`)来实现监测诊断。

## 两种探针

- **livenessProbe**: 用于探测容器是否处于`Running`状态，如果该探针返回失败，`kubelet`将会杀掉容器，并根据`restart policy`来决定是否重新创建该容器。如果没有配置该探针，默认返回成功的状态，只有容器`crash`，才会触发失败状态返回。
- **readinessProbe**: 用于探测容器是否可以处理服务请求，如果该探针失败，端点控制器将会把该`Pod`的IP从关联的`Service`中删除掉。如果没有配置该探针，默认返回成功的状态。

## 三种操作

- **ExecAction**: 在容器中执行命令行，如果命令的退出状态是0，则认为探针的状态是成功。
- **TCPSocketAction**: 向容器指定端口上发送TCP请求，如果该端口已被监听，则认为探针的状态是成功。
- **HTTPGetAction**: 向容器指定端口和路径发送HTTP GET请求，如果返回状态码处于200到400之间，则认为探针的状态是成功。

## 四种场景

- **Default**: 不配置探针时，容器处于不健康的状态(如`crash`)时，`kubelet`也会杀掉容器；容器正常初始化后，就认为是可以提供服务的状态。
- **Custom**: 在某种情况下，进程无法正常提供功能，但容器依然处于健康状态，则可以通过配置`liveness`探针实现杀掉容器； 进程初始化事件比较长，则可以通过配置`readiness`探针实现服务可用。
- **Reset**: 某些进程处于中间过程状态，但又希望从初始状态开始时，可以通过配置`liveness`探针实现，同时提供复位接口，如请求复位接口，则探针返回失败状态，从而实现复位操作。默认返回成功状态。
- **OutOfService**: 在进行服务升级时，需要将服务临时下线，可以通过配置`readiness`探针实现，同时提供服务下线接口，如请求下线接口，则探针返回失败状态，从而实现下线操作。默认返回成功状态。

*参考:*

- [*Pod Lifecycle - Container probes*](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes)
- [*Configure Liveness and Readiness Probes*](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)
- <http://blog.cuicc.com/blog/2017/07/23/kubernetes-probe/>