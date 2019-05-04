# The-FIJI-Collection

This Repository contains multiple [Fiji][w1] scripts, which facilitate and automates various image processing steps.
All scripts were written in the [Fiji][w1] macro language

1. [autostitcher](#autostitcher) _written for Daniel Heutschi_
2. [multicrop.ijm](#multicrop) _written for Benjamin Sellner_
3. [MPSmovieMaker.ijm](#MPSmovieMaker)
4. [batch-32bitconverter.ijm](#32bitconverter)
5. [batch_segmentation_script.ijm](#segmentation)


<a name="autostitcher"></a>

## autostitcher.ijm

This script was written for Daniel Heutschi. 

__Input__: Tiles scans acquired with Leica Point Scanning Confocal "Sp5-II-Matrix".  
__Problem__: Autostitching of the tile scans by the Leica software LAS AF _v 2.6.0.7266_ produces
slight shifts/stitching errors. 

__Solution__:
The script [autostitcher.ijm][1] allows to stitch multiple tile-scanning .lif files in batch. 
It allows the user to choose a source directory containing the .lif files and a destination directory, where
the final, stitched images will be saved. It further allows the user to specify the output file format and
select between two stitching options:

__Options__:

- __Grid__: will use the Grid/Collection stitching based on the metadata of the file. The plugin has been written by
Preibisch et al., Bioinformatics (2009).
- __inLine__: will use Pairwise stitching(plugin written by Preibisch et al., Bioinformatics (2009)) and stitch the 
single tiles with each other one by one.  
_!Note: This function has been written only for tiles acquired in line!_

The stitched image is further saved in the specified destination folder in the specified file format. The script further
continues to stitch all .lif files in the specified Input folder. 



<a name="multicrop"></a>

## multicrop.ijm
This script [multicrop.ijm][2]was written for Benjamin Sellner.

__Input__: any image supported by FIJI.  
__Problem__: The Image needs to be divided in multiple subimages e.g. 20x20 images.  
__Solution__: The script will split/divide the open/selected image according to the desired amount of rows and
 columns specified by the user.


<a name="MPSmovieMaker"></a>

## MPSmovieMaker.ijm

_!Note: This script is also part of the ImageProcessingPipeline-PE!_

The script [MPSmovieMaker.ijm][3] allows to process and analyse _any_ (Hyperstack) image supported by the [Bio-Formats
Plugin][w2]. It generates a maximum projection of the Hyperstack. The Maximum projection is further displayed
as composite side by side with the maximumprojection of the single channels displayed in inverted greyscale.

__Input__: any image supported by Bio-Formats Plugin.  
__Task__: generation of maximum projection and side by side display of the single channels in inverted grey scale and 
generation of a final movie. Ideal: Possibility to choose between complete automated processing and semi-automated processing

__Solution__:
The script allows choosing a source directory, containing multiple image data files and a destination directory. 
Further it allows to choose the file input format(e.g. ics). For each file, with the correct file ending, a maximum
 projection is generated and a composite movie together with inverted greyscale single channel movies are combined with
 each other. The resulting movie is saved as .avi file and optionally the resulting image file can be saved additionally.
 The operator can choose if the files are processed:
- __automatically__: Brightness and Contrast is set with automatic thresholds
- __semi-automatic__: allows individual cropping of the data and manuel setting of Brightness and Contrast.

The combined, final movie will contain a time stamp and scale bar.

[MPSmovieMaker.ijm][3] is a batch script; it will process all files with the specified file format in the specified Input folder.
An older version and less functionalized script with a similar purpose is: [deprecated_MPSmovieMaker.ijm][4].

Picture of final movie file:
![Example picture of MPS script Result][p1]


Link to an example result of MPSmovieMaker:  
[Result of MPSmovieMaker (.avi file)][m1]
 
 
<a name="32bitconverter"></a>

# batch-32bitconverter
.... under construction ...



<a name="segmentation"></a>

# batch_segmentation_script.ijm

.... under construction ...





[w1]: https://imagej.net/Welcome
[w2]: https://imagej.net/Bio-Formats

[p1]: https://github.com/EtienneEs/ImageProcessingPipeline-PE/blob/master/picture_of_MPSmovieMaker_result.png

[m1]: https://github.com/EtienneEs/ImageProcessingPipeline-PE/blob/master/MPS_example.avi

[1]: ../master/autostitcher.ijm
[2]: ../master/multicrop.ijm
[3]: ../master/MPSmovieMaker.ijm
[4]: ../master/deprecated_MPSmovieMaker.ijm