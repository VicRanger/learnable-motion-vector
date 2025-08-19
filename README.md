# Adaptive Recurrent Frame Prediction with Learnable Motion Vectors [SIGGRAPH ASIA 2023 Conference Paper]

This is offical repository for our paper, **Adaptive Recurrent Frame Prediction with Learnable Motion Vectors**<br>
**Authors:** Zhizhen Wu, Chenyu Zuo, Yuchi Huo, Yazhen Yuan, Yinfan Peng, Guiyang Pu, Rui Wang and Hujun Bao.<br>
in SIGGRAPH Asia 2023 Conference Proceedings

![pic](asset/pic.png)

> **Summary:** We propose **learnable motion vectors**, a novel approach that leverages both **optical flow** and traditionally **rendered motion vectors** to facilitate accurate motion estimation for challenging elements such as **occlusion, dynamic shading, and translucent objects**. Building on this concept, our new **feature streaming neural network**, FSNet, is designed to **achieve adaptive recurrent frame prediction** with lower latency and superior quality.

# Updates
```
[2025-08-19]: Updated the outdated resource links.
```
# Setup

1. Make a directory for workspace and clone the repository: 
```
mkdir learnable-motion-vector; cd learnable-motion-vector
git clone https://github.com/VicRanger/learnable-motion-vector code
cd code
```
2. Install conda env: `scripts/create_env.sh` in Linux or `scripts/create_env.bat` in Windows

# Dataset Generation

## Export Buffers from UE4

Corresbonding cpp code can be found in `scripts/ue4_source_code/`. <br>
1. Copy the .h and .cpp files into the source directory of the UE4 project, and then recompile the project. <br>
2. Upon succesful compilation, there will be a new C++ Class in the `Content Browser`. This class functions as a placable Actor. To begin using the capture functionality, place the `CaptureManager` into scene, configure it and then you are ready to begin exporting the render buffer.

## Exported File Structure from UE4
```
Root_Directory/
|-- BaseColor
| |-- frame_0.EXR
| |-- frame_1.EXR
| |-- ...
| |-- frame_10.EXR
| |-- frame_11.EXR
| |-- ...
| |-- frame_100.EXR
| |-- frame_101.EXR
| |-- ...
|-- MetallicRoughnessStencil
|-- NoVSpecular
|-- STAlpha
|-- SceneColor
|-- SceneColorNoST
|-- SkyColor
|-- SkyDepth 
|-- VelocityDepth
|-- WorldNormal
```
## Compress Raw Files into NPZ Files
### Setup configs
Edit the `dataset_export_job_st.yaml` configuration file located at `config/includes/`. (`st` stands for `separate transluceny`)<br>
Within this file, configure the following paths:
- Set the `import_path` parameter to specify the directory containing the source EXR files exported from Unreal Engine.
- Set the `export_path` parameter to define where the processed NPZ datasets to be saved.
- Populate the `scene` array item to specify the name of the scene directory containing the source images.

### Run the script
```
python src/test/test_export_buffer.py --config config/export/export_st.yaml
```
### Addtional options 
In the `config/export/export_st.yaml` file:

`num_thread: 8`: The num_thread setting specifies the number of threads used for parallel export. Setting this to 0 disables multiprocessing.

`overwrite: true`: Set this to false to resume an export rather than overwrite existing files.

# Training
## Training from Scratch
Requirements: exported npz files, and a yaml file.

Run the script with `--train`:
```
python src/test/test_trainer.py --config config/shadenet_v5d4.yaml --train
```
### Configuration options
- `initial_inference: false`: The initial_inference can be set to false to skip an initial dummy inference, used for timing.
- `dataset.path: "/path/to/export_data/"`: The dataset.path setting specifies the path to the exported NumPy data files, which should end with a trailing slash "/".
## Resume the Previous Training
Requirements: generated training result in a standardized directory structure, e.g. 
```
job_name (e.g., shadenet_v5d4_FC)/
|-- time_stamp(e.g., 2024-MM-DD_HH-MM-SS)
| |-- log (logs in text format)
| |-- model (the models' pt of the best and the newest)
| |-- writer (logs in tensorboard format)
| |-- checkpoint (the last checkpoint)
| |-- history_checkpoints (all history checkpoints)
```
Run the script with `--train --resume`:
```
python src/test/test_trainer.py --config config/shadenet_v5d4.yaml --train --resume
```
As long as parent directory path `job_name/time_stamp` is valid and the directory `checkpoint` exists, the training will restart from the last saved checkpoint.
## Testing
Requirements: generated training result.

run the script with `--test`:
```
python src/test/test_trainer.py --config config/shadenet_v5d4.yaml --test
```
## Testing with pretrained model
Requirements: the `.pt` file containing dict_state of model (can be found in  `model` inside training result directory). The checkpoints are not required.

Run the script with `--test` plus `--test_only`:
```
python src/test/test_trainer.py --config config/shadenet_v5d4.yaml --test --test_only
```

#  Inference
Requirements: the .pt model file, (can be found in  `model` inside training result directory).
- Place .pt file in `output/checkpoints/`
- Set `pre_model: "../output/checkpoints/model.pt"` in the yaml.
- Then run the script
```bash
python src/test/test_inference.py
```

# Running the Demo
## Step 1: download the resources
```
./scripts/download_pretrained_model_demo.sh
./scripts/download_dataset_demo.sh
```
(alternative) or download with the following links
1. download [pretraineed model (Hugging Face) (8.4MB)](https://huggingface.co/VicRanger/learnable-motion-vector-v5d4-pretrained-FC-demo/resolve/main/lmv_v5d4_FC_demo.pt?download=true) and place it in `../checkpoints`
2. download [dataset sample (Hugging Face) (378MB)](https://huggingface.co/datasets/VicRanger/learnable-motion-vector-dataset-demo/resolve/main/FC.zip?download=true) and unzip it to `../dataset/`

## Step 2: run the demo
by `test_trainer.py` with `test_only` mode 
```
python src/test/test_train.py --config config/lmv_v5d4_inference.yaml --test --test_only
```
or by default `test_inference.py`
```
python src/test/test_inference.py
```
# Citation

Thank you for being interested in our paper.  <br>
If you find our paper helpful or use our work in your research, please cite:
```
@inproceedings{10.1145/3610548.3618211,
author = {Wu, Zhizhen and Zuo, Chenyu and Huo, Yuchi and Yuan, Yazhen and Peng, Yifan and Pu, Guiyang and Wang, Rui and Bao, Hujun},
title = {Adaptive Recurrent Frame Prediction with Learnable Motion Vectors},
year = {2023},
isbn = {9798400703157},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
url = {https://doi.org/10.1145/3610548.3618211},
doi = {10.1145/3610548.3618211},
booktitle = {SIGGRAPH Asia 2023 Conference Papers},
articleno = {10},
numpages = {11},
keywords = {Frame Extrapolation, Real-time Rendering, Spatial-temporal},
location = {, Sydney, NSW, Australia, },
series = {SA '23}
}
```


# Contact
`:)` If you have any questions or suggestions about this repo, please feel free to contact me (jsnwu99@gmail.com).
