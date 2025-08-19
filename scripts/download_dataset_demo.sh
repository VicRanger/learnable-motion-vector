mkdir ../dataset
hf download VicRanger/learnable-motion-vector-dataset-demo FC.zip --repo-type dataset --local-dir ../dataset/
unzip ../dataset/FC.zip -d ../dataset/
rm ../dataset/FC.zip