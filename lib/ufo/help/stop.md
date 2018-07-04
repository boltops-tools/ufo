ECS deployments can sometimes take a while. One reason could be because the old ECS tasks can take some time to drain and removed. The recommended way to speed this draining process up is configuring the `deregistration_delay.timeout_seconds` to a low value.  You can configured this in `.ufo/settings/cfn/default.yml`. For more info refer to http://localhost:4000/docs/settings-cfn/  This setting works well for Application Load Balancers.

However, for Network Load Balancers, it seems like the deregistration_delay is not currently being respected. In this case, it take an annoying load time and this command can help speed up the process.

The command looks for any extra old ongoing deployments and stops the tasks associated with them.  This can cause errors for any inflight requests.

    ufo stop demo-web
