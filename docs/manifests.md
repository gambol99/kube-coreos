## **Kube Manifests**

Once a instance is bootstraped, secore or compute, one manifests exists by default (written in by the cloud-config): kube-manifests. Kube Manifests is essentially how the services bootstrap themselves and other services they are required the to

```YAML
- path: /etc/kubernetes/manifests/kube-manifests.yml
  permissions: 0444
  owner: root
  content: |
    apiVersion: v1
    kind: Pod
    metadata:
      name: kube-manifests
      namespace: kube-system
    spec:
      hostNetwork: true
      containers:
      - name: manifests
        image: {{ .kmsctl_image }}
        args:
        - --region={{ .aws_region }}
        - get
        - --output-dir=/etc/kubernetes/manifests
        - --bucket={{ .secrets_bucket_name }}
        - --sync=true
        - --recursive=true
        - manifests/compute
        - manifests/common
        volumeMounts:
        - name: manifests
          mountPath: /etc/kubernetes/manifests
      volumes:
      - name: manifests
        hostPath:
          path: /etc/kubernetes/manifests
```

Once the kubelet is up and running the kube-manifest is loaded and starts downlading additional manifests (polling every 30s by default for updates). In the master / secure layers case, kube-manifests is used to pull down the static pod definitions for the api, controller, scheduler and kube-addons. Each layer is locked down via iam roles to only see the files under there specific layer in the secret bucket i.e. compute can only pull from s3/bucket/manifests/{compute,common}.
