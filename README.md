# RKNN Inference on Edge Devices

RKNN software helps users deploy AI models quickly onto Rockchip chips. The overall framework is as follows:

[![RKNN](https://github.com/rockchip-linux/rknn-toolkit2/raw/master/res/framework.png)](https://github.com/rockchip-linux/rknn-toolkit2/blob/master/res/framework.png)

To use RKNPU, users first need to run the RKNN-Toolkit2 tool on their computers to convert the trained model into the RKNN format. After that, they can perform inference on the development board using RKNN C API or Python API.

- RKNN-Toolkit2 is a software development toolkit for executing model conversion, inference, and performance evaluation on PC and Rockchip NPU platforms.
- RKNN-Toolkit-Lite2 provides a Python programming interface for Rockchip NPU platforms, helping users deploy RKNN models and accelerate AI applications.
- RKNN Runtime provides a C/C++ programming interface for Rockchip NPU platforms, assisting users in deploying RKNN models and accelerating AI applications.
- RKNPU kernel driver is responsible for interacting with the NPU hardware. It's open source and can be found in the Rockchip kernel code.

### Supported Platforms

- RK3566/RK3568 Series

- RK3588 Series

- RK3562 Series

- RV1103/RV1106

  

## Configure RKNN Environment

### Configuration on PC with RKNN-Toolkit2

1. Download the RKNN repository.

   It is recommended to create a new directory to store the RKNN repository. For example, create a folder named "Projects" and store the RKNN-Toolkit2 v1.6.0 and RKNN Model Zoo v1.6.0 repositories in that directory. The commands are as follows:

   ```bash
   # Create Projects folder
   mkdir Projects
   # Enter the directory
   cd Projects
   # Download RKNN-Toolkit2 repository
   git clone https://github.com/airockchip/rknn-toolkit2.git
   cd rknn-toolkit2
   git checkout v1.6.0
   cd ..
   # Download RKNN Model Zoo repository
   git clone https://github.com/airockchip/rknn_model_zoo.git 
   cd rknn_model_zoo
   git checkout v1.6.0
   ```
2. *(Optional) Install [Anaconda](https://www.anaconda.com/)*

   If Python 3.8 (recommended version) is not installed on your system or if there are multiple Python environments, it's recommended to use [Anaconda](https://www.anaconda.com/) to create a new Python 3.8 environment.
   2.1 Install Anaconda

   In the terminal window, execute the following commands to check if Anaconda is installed. If already installed, you can skip this step.

   ```bash
   $ conda --version
   conda 23.10.0
   ```

   If "conda: command not found" appears, it means Anaconda is not installed. Follow the Anaconda official website for installation:

   ```bash
   wget https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh
   bash Anaconda3-2023.09-0-Linux-x86_64.sh
   ```

   2.2 Create a conda environment

   ```bash
   conda create -n rknn python=3.8
   ```

   Activate the rknn conda environment

   ```bash 
   conda activate rknn
   ```

   *Deactivate the environment*

   ```bash 
   deactivate
   ```

3. Install dependencies and RKNN-Toolkit2

   After activating the conda rknn environment, go to the rknn-toolkit2 directory, install dependencies according to requirements_cpxx.txt, and install RKNN-Toolkit2 using the wheel package. The commands are as follows:

   ```bash
   # Enter the rknn-toolkit2 directory
   cd Projects/rknn-toolkit2/rknn-toolkit2
   # Depending on the Python version, choose the appropriate requirements file
   # For example, python3.8 corresponds to requirements_cp38.txt
   pip install -r packages/requirements_cpxx.txt -i https://mirror.baidu.com/pypi/simple
   # Install RKNN-Toolkit2
   # Depending on the Python version and processor architecture, choose the appropriate wheel installation package:
   # Replace x.x.x with the version number of RKNN-Toolkit2, xxxxxxxx with the commit number, and cpxx with the Python version number as needed
   pip install packages/rknn_toolkit2-x.x.x+xxxxxxxx-cpxx-cpxx-linux_x86_64.whl
   ```

4. Verify successful installation

   Execute the following commands. If there are no errors, RKNN-Toolkit2 environment is successfully installed.

   ```bash
   # Enter Python interactive mode
   python3
   # Import the RKNN class
   from rknn.api import RKNN
   ```



### Configure Edge-side RKNN Toolkit Lite2 and its Dependencies

```bash
sudo apt update
sudo apt install rknpu2-rk3588 python3-rknnlite2    #SOC for RK3588 series
# sudo apt install rknpu2-rk356x python3-rknnlite2    #SOC for RK356X series
```



## Deploying YOLOv8 Example on board

This example uses a pre-trained ONNX format model from the rknn_model_zoo to demonstrate the complete process of model conversion and inference on the edge using the RKNN SDK.

To deploy YOLOv8 with RKNN SDK, follow these two steps:

1. **Model Conversion on PC using rknn-toolkit2:**

   Download the YOLOv8.onnx model.

   ```bash
   # Activate the rknn conda environment and navigate to the respective directory
   cd Project/rknn_model_zoo/examples/yolov8/model
   # Download the pre-trained yolov8n.onnx model
   bash download_model.sh
   ```

   Convert it to yolov8.rknn.

   ```bash
   cd Project/rknn_model_zoo/examples/yolov8/python
   python3 convert.py ../model/yolov8n.onnx rk3588
   ```

   *Description:*

   - `<onnx_model>`: Specify the path to the ONNX model.
   - `<TARGET_PLATFORM>`: Specify the NPU platform name. Refer to [here](#Supported-Platforms) for supported platforms.
   - `<dtype>`(optional): Specify as `i8` for quantization or `fp` for no quantization. Defaults to `i8`.
   - `<output_rknn_path>`(optional): Specify the path to save the RKNN model. Defaults to the same directory as the ONNX model with the filename `yolov8.rknn`.

   Copy the yolov8.rknn model to the edge device.

2. **Edge-side YOLOv8 Inference:**

   Download the source code for YOLOv8 edge inference and install the required dependencies.

   ```bash
   # recommand install in virtualenv 
   pip3 install opencv-python-headless scipy
   ```

   Place the copied yolov8n.rknn in this directory.

   Run the yolov8_lite.py script.

   ```bash
   $ python3 yolov8_lite.py 
   ```

   The results of all inferences are saved in the ./result directory.

   *Description:*

   - `--model_path`: Specify the rknn model path.
   - `--target`: Specify the NPU platform name, default is rk3588. Refer to [here](#Supported-Platforms) for supported platforms.
   - `--img_folder`: Directory containing images for inference, default is ./imgs
   - `--img_save`: Whether to save the inference result images to ./result, default is True