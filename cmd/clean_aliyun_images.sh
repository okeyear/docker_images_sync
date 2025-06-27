
#!/bin/bash
# 需提前安装aliyun-cli并配置AK：https://help.aliyun.com/document_detail/121258.html
# todo: 再见一个github action, 定期执行这个脚本， 清理镜像

# 配置区域和仓库（根据实际情况修改）
REGION="cn-hangzhou"
REPO_NAMESPACE="your-namespace"
REPO_NAME="your-repo-name"
CUTOFF_DATE=$(date -d "6 months ago" +%s)

# 获取镜像列表
IMAGE_LIST=$(aliyun cr GetRepoTag --RegionId $REGION --RepoNamespace $REPO_NAMESPACE --RepoName $REPO_NAME | jq -r '.data.tags[] | "\(.tag) \(.imageCreate)"')

# 清理旧镜像
while read -r line; do
    TAG=$(echo $line | awk '{print $1}')
    CREATE_TIME=$(echo $line | awk '{print $2}')
    TIMESTAMP=$(date -d "$CREATE_TIME" +%s)

    if [ $TIMESTAMP -lt $CUTOFF_DATE ]; then
        echo "Deleting $REPO_NAMESPACE/$REPO_NAME:$TAG (Created: $CREATE_TIME)"
        aliyun cr DeleteImage --RegionId $REGION --RepoNamespace $REPO_NAMESPACE --RepoName $REPO_NAME --Tag $TAG
    fi
done <<< "$IMAGE_LIST"