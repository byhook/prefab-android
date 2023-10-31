## lame预构建库

#### 方式一：一键构建并发布到本地仓库

````bash
gradle clean publishToMavenLocal
````

#### 方式二：分步构建

````bash
#先构建lame库
bash build_lame.sh
#发布prefab预构建库
bash build_prefab_v2.sh
````

本地仓库发布路径：
````bash
～/.m2/repository/io/github/byhook/lame/3.100.0
````