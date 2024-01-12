# Linux RKNN 板端推理 

RKNN软件可以帮助用户快速部署AI模型到 Rockchip 芯片上。整体框架如下：

[![RKNN](https://github.com/rockchip-linux/rknn-toolkit2/raw/master/res/framework.png)](https://github.com/rockchip-linux/rknn-toolkit2/blob/master/res/framework.png)

为了使用RKNPU，用户首先需要在计算机上运行RKNN-Toolkit2工具，将训练好的模型转换为RKNN格式的模型，然后在开发板上使用RKNN C API或Python API进行推断。

- RKNN-Toolkit2是一个软件开发工具包，供用户在PC和Rockchip NPU平台上执行模型转换、推断和性能评估。
- RKNN-Toolkit-Lite2为Rockchip NPU平台提供了Python编程接口，帮助用户部署RKNN模型并加速实施AI应用。
- RKNN Runtime为Rockchip NPU平台提供了C/C++编程接口，帮助用户部署RKNN模型并加速实施AI应用。
- RKNPU内核驱动负责与NPU硬件交互。已经开源，可以在Rockchip内核代码中找到。

### 支持平台

- RK3566/RK3568 系列
- RK3588 系列
- RK3562 系列
- RV1103/RV1106



## 配置RKNN环境

### PC端配置 RKNN-Toolkit2 环境

1. 下载 RKNN 仓库

   建议新建一个目录用来存放 RKNN 仓库，例如新建一个名称为 Projects 的文件夹，并将
   RKNN-Toolkit2 v1.6.0和 RKNN Model Zoo v1.6.0 仓库存放至该目录下，参考命令如下

   ```bash
   # 新建 Projects 文件夹
   mkdir Projects
   # 进入该目录
   cd Projects
   # 下载 RKNN-Toolkit2 仓库
   git clone https://github.com/airockchip/rknn-toolkit2.git
   cd rknn-toolkit2
   git checkout v1.6.0
   cd ..
   # 下载 RKNN Model Zoo 仓库
   git clone https://github.com/airockchip/rknn_model_zoo.git 
   cd rknn_model_zoo
   git checkout v1.6.0
   ```

2. *(Option)安装 [Anaconda](https://www.anaconda.com/)*

   如果系统中没有安装 Python 3.8（建议版本），或者同时有多个版本的 Python 环境，建议
   使用 [Anaconda](https://www.anaconda.com/) 创建新的 Python 3.8 环境。
   2.1 安装 Anaconda
   在计算机的终端窗口中执行以下命令，检查是否安装 Anaconda，若已安装则可省略此节步骤。

   ```bash
   $ conda --version
   conda 23.10.0
   ```

   如出现 conda: command not found, 则表示未安装anaconda, 请参考 Anaconda 官网进行安装

   ```bash
   wget https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh
   bash Anaconda3-2023.09-0-Linux-x86_64.sh
   ```

   2.2 创建 conda 环境

   ```bash
   conda create -n rknn python=3.8
   ```

   进入 rknn conda 环境

   ```bash 
   conda activate rknn
   ```

   *退出环境*

   ```bash 
   deactivate
   ```

3. 安装依赖库和 RKNN-Toolkit2

   激活 conda rknn 环境后，进入 rknn-toolkit2 目录，根据 requirements_cpxx.txt 安装依赖
   库，并通过 wheel 包安装 RKNN-Toolkit2，参考命令如下:

   ```bash
   # 进入 rknn-toolkit2 目录
   cd Projects/rknn-toolkit2/rknn-toolkit2
   # 请根据不同的 python 版本，选择不同的 requirements 文件
   # 例如 python3.8 对应 requirements_cp38.txt
   pip install -r packages/requirements_cpxx.txt -i https://mirror.baidu.com/pypi/simple
   # 安装 RKNN-Toolkit2
   # 请根据不同的 python 版本及处理器架构，选择不同的 wheel 安装包文件：
   # 其中 x.x.x 是 RKNN-Toolkit2 版本号，xxxxxxxx 是提交号，cpxx 是 python 版本号，请根据实际数值进行替换
   pip install packages/rknn_toolkit2-x.x.x+xxxxxxxx-cpxx-cpxx-linux_x86_64.whl
   ```

4. 验证是否安装成功

   执行以下命令，若没有报错，则代表 RKNN-Toolkit2 环境安装成功。

   ```bash
   # 进入 Python 交互模式
   python3
   # 导入 RKNN 类
   from rknn.api import RKNN
   ```




### 配置板端 RKNN Toolkit Lite2 及其所需依赖

```bash
sudo apt update
sudo apt install rknpu2-rk3588 python3-rknnlite2    #SOC为RK3588系列
# sudo apt install rknpu2-rk356x python3-rknnlite2    #SOC为RK356X系列
```



## 板端部署 YOLOv8 示例

此示例用rknn_model_zoo中预训练好的 ONNX 格式模型为例子通过模型转换到板端推理做完整示例 

利用 RKNN SDK 部署YOLOv8 需要两个步骤

- PC端利用rknn-toolkit2将不同框架下的模型转换成rknn格式模型
- 板端利用 rknn-toolkit2-lite 的 Python API 板端推理模型



### PC端模型转换

下载 yolov8.onnx 模型

```bash
# 请提前激活 rknn conda 环境并进入相应目录
cd Project/rknn_model_zoo/examples/yolov8/model
# 下载预训练好的yolov8n.onnx模型
bash download_model.sh
```

转换成yolov8.rknn

```bash
cd Project/rknn_model_zoo/examples/yolov8/python
python3 convert.py ../model/yolov8n.onnx rk3588
```

*描述:*

- `<onnx_model>`: 指定ONNX模型路径。
- `<TARGET_PLATFORM>`: 指定NPU平台名称。支持的平台请参考[这里](#支持平台)。
- `<dtype>(可选)`: 指定为 `i8` 或 `fp`。`i8` 用于量化，`fp` 用于不进行量化。默认为 `i8`。
- `<output_rknn_path>(可选)`: 指定RKNN模型的保存路径，默认保存在与ONNX模型相同的目录中，文件名为 `yolov8.rknn`

将 yolov8.rknn 模型拷贝到板端



### 板端推理 YOLOv8

下载YOLOv8板端推理源码包并安装所需依赖

```bash
pip3 install opencv-python-headless scipy
```

将PC端拷贝过来的yolov8n.rknn放入此目录

运行 yolov8_lite.py 脚本

```bash
$ python3 yolov8_lite.py 
{'model_path': './model/yolov8n.rknn', 'target': 'rk3588', 'img_folder': './imgs', 'img_save': True}
--> Load RKNN model
done
--> Init runtime environment
I RKNN: [07:47:42.798] RKNN Runtime Information, librknnrt version: 1.6.0 (9a7b5d24c@2023-12-13T17:31:11)
I RKNN: [07:47:42.798] RKNN Driver Information, version: 0.8.2
W RKNN: [07:47:42.798] Current driver version: 0.8.2, recommend to upgrade the driver to the new version: >= 0.8.8
I RKNN: [07:47:42.798] RKNN Model Information, version: 6, toolkit version: 1.6.0+81f21f4d(compiler version: 1.6.0 (585b3edcf@2023-12-11T15:49:11)), target: RKNPU v2, target platform: rk3588, framework name: ONNX, framework layout: NCHW, model inference type: static_shape
W RKNN: [07:47:42.830] query RKNN_QUERY_INPUT_DYNAMIC_RANGE error, rknn model is static shape type, please export rknn with dynamic_shapes
W Query dynamic range failed. Ret code: RKNN_ERR_MODEL_INVALID. (If it is a static shape RKNN model, please ignore the above warning message.)
done
--> Running model 89.jpg
IMG: 000000000089.jpg
knife  @ (552 99 578 238) 0.850
knife  @ (529 102 556 236) 0.795
knife  @ (504 106 526 235) 0.771
knife  @ (477 126 497 232) 0.687
knife  @ (572 100 599 239) 0.416
microwave  @ (0 48 122 190) 0.827
oven  @ (138 202 476 477) 0.933
Detection result save to ./result/000000000089.jpg

--> Running model 82.jpg
IMG: 000000000382.jpg
person @ (512 362 559 446) 0.851
person @ (494 222 529 252) 0.544
person @ (479 273 495 288) 0.274
skis @ (483 427 573 457) 0.379
Detection result save to ./result/000000000382.jpg

--> Running model 25.jpg
IMG: 000000000625.jpg
person @ (276 151 370 423) 0.919
person @ (405 207 522 417) 0.905
person @ (186 233 276 419) 0.903
frisbee @ (272 111 307 132) 0.830
Detection result save to ./result/000000000625.jpg

--> Running model 
IMG: bus.jpg
person @ (211 241 283 507) 0.884
person @ (109 235 224 536) 0.879
person @ (477 223 560 521) 0.874
person @ (80 327 116 513) 0.330
bus  @ (99 135 550 456) 0.850
Detection result save to ./result/bus.jpg
```

所有推理结果保存在 ./result 中

*描述:*

- `--model_path`: 指定rknn模型路径。
- `--target`: 指定NPU平台名称, 默认 rk3588。支持的平台请参考[这里](#支持平台)。
- `--img_folder`: 进行推理的图片库, 默认 ./imgs
- `--img_save`: 是否保存推理结果图到./result, 默认 True















