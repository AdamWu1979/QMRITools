(* ::Package:: *)

(* ::Title:: *)
(*DTITools ElastixTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*Begin Package*)


BeginPackage["DTITools`ElastixTools`"];
$ContextPath=Union[$ContextPath,System`$DTIToolsContextPaths];

Unprotect @@ Names["DTITools`ElastixTools`*"];
ClearAll @@ Names["DTITools`ElastixTools`*"];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection::Closed:: *)
(*Fuctions*)


RegisterData::usage =
"RegisterData[data] registers the data series. If data is 3D it performs multiple 2D registration, if data is 4D it performs multipe 3D registration. The target is the first image orvolume in the series.
RegisterData[{data, vox}] registers the data series using the given voxel size.
RegisterData[{data, mask}] registers the data series only using data whithin the mask.
RegisterData[{data, mask, vox}] registers the data series using the given voxel size only using data within the mask.

RegisterData[target, moving] registers the moving data to the target data. target can be 2D or 3D. moving can be the same of one dimension higher than the target.
RegisterData[{target, mask, vox},{moving, mask, vox}] registers the data using the given voxel size only using data within the mask.
RegisterData[{target, vox}, moving] registers the data using the given voxel size.
RegisterData[target, {moving, vox}] registers the data using the given voxel size.
RegisterData[{target, vox}, {moving, vox}] registers the data using the given voxel size.

RegisterData[{target, mask}, moving] registers the data series only using data whithin the mask.
RegisterData[target, {moving, mask}] registers the data series only using data whithin the mask.
RegisterData[{target, mask}, moving] registers the data series only using data whithin the mask.
RegisterData[{target, mask}, {moving, mask}] registers the data series only using data whithin the mask.

RegisterData[target, {moving, mask, vox}] registers the data series using the given voxel size only using data within the mask.
RegisterData[{target, mask}, {moving, mask, vox}] registers the data series using the given voxel size only using data within the mask.
RegisterData[{target, vox}, {moving, mask, vox}] registers the data series using the given voxel size only using data within the mask.
RegisterData[{target, mask, vox}, moving] registers the data series using the given voxel size only using data within the mask.
RegisterData[{target, mask, vox}, {moving, mask}] registers the data series using the given voxel size only using data within the mask.
RegisterData[{target, mask, vox}, {moving, vox}] registers the data series using the given voxel size only using data within the mask.
RegisterData[{target, mask}, {moving, vox}] registers the data series using the given voxel size only using data within the mask.
RegisterData[{target, vox}, {moving, mask}] registers the data series using the given voxel size only using data within the mask.

output is the registered data with the dimensions of the moving data. If OutputTransformation is True it also outputs the translation, rotation scale and skew of all images or volumes."

RegisterCardiacData::usage =
"RegisterCardiacData[data] registers the data using a 2D algorithm. data can be 3D or 4D.  
RegisterCardiacData[{data,vox}] registers the data series using the given voxel size.
RegisterCardiacData[{data,mask}] registers the data series only using data whithin the mask.
RegisterCardiacData[{data,mask,vox}] registers the data series using the given voxel size only using data within the mask."

RegisterDiffusionData::usage =
"RegisterDiffusionData[{dtidata, vox}] registers a diffusion dataset. dtidata should be 4D {slice, diff, x, y}. vox is the voxelsize of the data.
RegisterDiffusionData[{dtidata, dtimask, vox}] registers the data series using the given voxel size only using data within the mask.
RegisterDiffusionData[{dtidata ,vox}, {anatdata, voxa}] registers a diffusion dataset. The diffusion data is also registered to the anatdata.
RegisterDiffusionData[{dtidata, dtimask, vox}, {anatdata, voxa}] registers the data series using the given voxel size only using data within the mask.
RegisterDiffusionData[{dtidata,vox}, {anatdata, anatmask, voxa}] registers the data series using the given voxel size only using data within the mask.
RegisterDiffusionData[{dtidata, dtimask, vox}, {anatdata, anatmask, voxa}] registers the data series using the given voxel size only using data within the mask.

output is the registered dtidata and, if anatdata is given, the registered dtidata in anatomical space. If OutputTransformation is True it also outputs the translation, rotation scale and skew of all images or volumes."

RegisterDataSplit::usage = 
"RegisterDataSplit[dtidata, vox] is identical to Register diffusion data however left and right side of the data are registered seperately.
RegisterDataSplit[{dtidata, vox}, {anatdata, voxa}] is identical to Register diffusion data however left and right side of the data are registered seperately.
RegisterDataSplit[{dtidata, dtimask, vox}, {anatdata, anatmask, voxa}] is identical to Register diffusion data however left and right side of the data are registered seperately."

ReadTransformParameters::usage = 
"ReadTransformParameters[directory] reads the tranfomation parameters generated by RegisterData. The directory should be the TempDirectory were the registration is stored. DeleteTempDirectory should be False"

CorrectGradients::usage = 
"CorrectGradients[grad, transformation] corrects the gradient directions grad with the tranformation parameters from RegisterData or RegisterDiffusionData."

CorrectBmatrix::usage = 
"CorrectBmatrix[bmat, transformation] corrects the bmatrix bmat with the tranformation parameters from RegisterData or RegisterDiffusionData."


(* ::Subsection::Closed:: *)
(*Options*)


Iterations::usage =
"Iterations gives the number of iterations used by the registration functions."

Resolutions::usage =
"Resolutions gives the number of scale space resolutions used by the registration functions."

HistogramBins::usage =
"HistogramBins gives the number of bins of the joined histogram used by the registration functions."

NumberSamples::usage =
"NumberSamples gives the number of random samples that are taken each iteration used by the registration functions."

OutputImage::usage =
"OutputImage specifies if the result image should be writen in the TempDirectory as nii file."

InterpolationOrderReg::usage =
"InterpolationOrderReg specifies the interpolation order used in the registration functions."

MethodReg::usage = 
"MethodReg spefifies which registration method to use. Mehtods can be be \"rigid\",\"affine\", \"bspline\" or \"cyclyc\"."

BsplineSpacing::usage =
"BsplineSpacing is the spacing of the bsplines if the method is \"bspline\"."

TempDirectory::usage = 
"TempDirectory is the temprary directory used to perform and output the registration."

DeleteTempDirectory::usage =
"DeleteTempDirectory specifies if the temp directory should be deleted after the registration is finisched."

PrintTempDirectory::usage = 
"PrintTempDirectory spefifies if the location of the temp directory should be deplayed."

RegistrationTarget::usage = 
"RegistrationTarget specifies which target to uses for registration in the functions RegisterDiffusionData and RegisterCardiacData. 
Values can be \"First\", \"Mean\" or \"Median\"."

BsplineDirections::usage = 
"BsplineDirections gives the direction in which the bsplines are allowed to move when registering diffusion data to anatomical space."

AffineDirections::usage = 
"AffineDirections gives the directions in which data can be moved when registering diffusion data to anatomical space."

OutputTransformation::usage =
"OutputTransformation specifies if the tranformation paramters (translation, rotation, scale and skew) should be given as output in the registration functions."

IterationsA::usage = 
"IterationsA gives the number of iterations used when registering diffusion data to anatomical space."

ResolutionsA::usage =
"ResolutionsA gives the number of scale space resolutions used when registering diffusion data to anatomical space."

HistogramBinsA::usage =
"HistogramBinsA gives the number of bins of the joined histogram used when registering diffusion data to anatomical space."

NumberSamplesA::usage =
"NumberSamplesA gives the number of random samples that are taken each iteration when registering diffusion data to anatomical space."

InterpolationOrderRegA::usage =
"InterpolationOrderRegA specifies the interpolation order used in the registration functions when registering diffusion data to anatomical space."
 
MethodRegA::usage =
"MethodRegA spefifies which registration method to use when registering diffusion data to anatomical space. Mehtods can be be \"rigid\",\"affine\" or \"bspline\"."


(* ::Subsection::Closed:: *)
(*Error Messages*)


RegisterData::vol="The `1`D datasets should have 2 or more volumes, it has `2` volumes."

RegisterData::dim="Datasets should both be 2D or 3D, or 2D and 3D, or 3D and 4D, current datasets are `1`D and `2`D."

RegisterData::dims="Dataset should be 3D or 4D, current dataset is `1`D."

RegisterData::vox="voxel size should be {z,x,y} and numeric, current sizes are `1` and `2`."

RegisterData::voxs="voxel size should be {z,x,y} and numeric, current size is `1`."

RegisterData::met="MethodReg should be \"rigid\",\"affine\", \"bspline\" or \"cyclyc\", current method is `1`."

RegisterData::metc="If the MethodReg is \"cyclyc\" no target can be given."

RegisterData::mask="The mask dimensions `1` should be equal to the data dimensions `2`."

RegisterData::dir="Temporary directory not created."

RegisterData::elastix="Elastix not found, check if DTITools is installed in the $BaseDirectory or $UserBaseDirectory."

RegisterData::par="`1` should be a number or a list of numbers with length `2`."

RegisterData::fatal="Fatal error encountered."


(* ::Section:: *)
(*Functions*)


Begin["`Private`"]


(* ::Subsection:: *)
(*Support Functions*)


(* ::Subsubsection::Closed:: *)
(*ParString*)


SchedulePar[res_,x_]:=ListToString[ToString[2^#1]<>" "<>ToString[2^#]<>" "<>ToString[x]&/@Reverse[Range[res]-1]];

ListToString[list_]:=StringJoin[Riffle[ToString/@list," "]]

ParString[{itterations_,resolutions_,bins_,samples_,intOrder_},{type_,output_},grid_:{30, 30, 30}, derscB_:{1,1,1}, derscA_:{1,1,1}]:="// *********************
// * "<>type<>"
// *********************

// *********************
// * ImageTypes
// *********************
(FixedInternalImagePixelType \"float\")
(MovingInternalImagePixelType \"float\")
(UseDirectionCosines \"true\")

// *********************
// * Components
// *********************
(ResampleInterpolator \"FinalBSplineInterpolator\")
(FixedImagePyramid \"FixedRecursiveImagePyramid\")
(MovingImagePyramid \"MovingRecursiveImagePyramid\")
(Registration \"MultiResolutionRegistration\")
"<>Switch[type,
"cyclyc",
"(Interpolator \"ReducedDimensionBSplineInterpolator\")
(Metric \"VarianceOverLastDimensionMetric\")",
_,
"(Interpolator \"BSplineInterpolator\")
(Metric \"AdvancedMattesMutualInformation\")"
]<>"
(BSplineInterpolationOrder 3)
(Resampler \"DefaultResampler\")
(Optimizer \"AdaptiveStochasticGradientDescent\")
"<>Switch[type,
"rigid",
"(Transform \"EulerTransform\")",
"rigidDTI",
"(Transform \"AffineDTITransform\")",
"affine",
"(Transform \"AffineTransform\")",
"affineDTI",
"(Transform \"AffineDTITransform\")
(MovingImageDerivativeScales "<>ToString[Clip[derscA[[3]]]] <> " " <>ToString[Clip[derscA[[2]]]] <> " " <> ToString[Clip[derscA[[1]]]]<>")",
"bspline",
"(Transform \"BSplineTransform\")
(FinalGridSpacingInPhysicalUnits "<>ToString[grid[[3]]]<>" "<>ToString[grid[[2]]]<>" "<>ToString[grid[[1]]]<>")
(MovingImageDerivativeScales "<>ToString[Clip[derscB[[3]]]] <> " " <>ToString[Clip[derscB[[2]]]] <> " " <> ToString[Clip[derscB[[1]]]]<>")",
"cyclyc",
"(Transform \"BSplineTransform\")
(UseCyclicTransform \"true\")
(FinalGridSpacingInPhysicalUnits "<>ToString[grid[[3]]]<>" "<>ToString[grid[[2]]]<>" 1)
(MovingImageDerivativeScales 1.0 1.0 0.0)

// *********************
// * Metric settings
// *********************
(SampleLastDimensionRandomly \"true\")
(NumSamplesLastDimension 5)
(SubtractMean \"true\")"
]<>"

// *********************
// * Mask settings
// *********************
(ErodeMask \"false\")
(ErodeFixedMask \"false\")

// *********************
// * Optimizer settings
// *********************
(NumberOfResolutions "<>ToString[resolutions]<>")
(MaximumNumberOfIterations "<>ToString[itterations]<>")
(AutomaticScalesEstimation \"true\")
(AutomaticTransformInitialization \"true\")
"<>Switch[type,
"cyclyc",
"(AutomaticParameterEstimation \"true\")
(GridSpacingSchedule "<>SchedulePar[resolutions,1]<>")",
_,
""
]<>"

// *********************
// * Transform settings
// *********************
(HowToCombineTransforms \"Compose\")

// *********************
// * Pyramid settings
// *********************
(NumberOfHistogramBins "<>ToString[bins]<>")
"<>Switch[type,
"affineDTI","(Scales -1.000000e+00 -1.000000e+00 -1.000000e+00  1.000000e+06  1.000000e+06  1.000000e+06  1.000000e+06  1.000000e+06  1.000000e+06 -1.000000e+00 -1.000000e+00 -1.000000e+00)",
"rigidDTI","(Scales -1.000000e+00 -1.000000e+00 -1.000000e+00  3.000000e+38  3.000000e+38  3.000000e+38  3.000000e+38  3.000000e+38  3.000000e+38 -1.000000e+00 -1.000000e+00 -1.000000e+00)",
"cyclyc",
"(ImagePyramidSchedule "<>SchedulePar[resolutions,0]<>")",
_,""
]<>"

// *********************
// * Sampler parameters
// *********************
(NumberOfSpatialSamples "<>ToString[samples]<>")
"<>Switch[type,
"cyclyc",
"(ImageSampler \"Random\")",
_,
"(ImageSampler \"RandomCoordinate\")"
]<>"
(CheckNumberOfSamples \"false\")
(NewSamplesEveryIteration \"true\")
(MaximumNumberOfSamplingAttempts 100)
(FinalBSplineInterpolationOrder "<>ToString[intOrder]<>")

// *********************
// * Output settings
// *********************
(DefaultPixelValue 0)
(WriteTransformParametersEachIteration \"false\")
(WriteResultImage  \""<>output<>"\")
(ResultImageFormat \"nii\")
(ResultImagePixelType \"float\")
"


(* ::Subsubsection::Closed:: *)
(*FindElastix*)


FindElastix[]:=Module[{fil1,fil2},
fil1=$UserBaseDirectory<>"\\Applications\\DTITools\\Applications\\elastix.exe";
fil2=$BaseDirectory<>"\\Applications\\DTITools\\Applications\\elastix.exe";
If[FileExistsQ[fil1],fil1,If[FileExistsQ[fil2],fil2,"error"]]
]


(* ::Subsubsection::Closed:: *)
(*FindTransformix*)


FindTransformix[]:=Module[{fil1,fil2},
fil1=$UserBaseDirectory<>"\\Applications\\DTITools\\Applications\\transformix.exe";
fil2=$BaseDirectory<>"\\Applications\\DTITools\\Applications\\transformix.exe";
If[FileExistsQ[fil1],fil1,If[FileExistsQ[fil2],fil2,"error"]]
]


(* ::Subsubsection::Closed:: *)
(*RunElastix*)


RunElastix[elastix_,tempdir_,parfile_,{inpfol_,movfol_,outfol_},{fixed_,moving_,out_},{maskf_,maskm_}]:=Module[
{command,inpfold,outfold,movfold,parfiles,copy,maskfFile,maskmFile},

inpfold=If[inpfol=="",tempdir,tempdir<>inpfol<>"\\"];
movfold=If[movfol=="",tempdir,tempdir<>movfol<>"\\"];
outfold=If[outfol=="",StringDrop[tempdir,-1],tempdir<>outfol];

maskfFile=If[maskf==="",""," -fMask \""<>tempdir<>maskf<>"\""];
maskmFile=If[maskm==="",""," -mMask \""<>tempdir<>maskm<>"\""];

parfiles=StringJoin[" -p \""<>tempdir<>#<>"\""&/@parfile];
copy=If[out=="","","copy \""<>tempdir<>outfol<>"\\result."<>ToString[Length[parfile]-1]<>".nii\" \""<>tempdir<>outfol<>"\\"<>out<>"\""];

command=
"\""<>elastix<>
"\" -f \""<>inpfold<>fixed<>
"\" -m \""<>movfold<>moving<>
"\" -out \""<>outfold<>"\""<>
maskfFile<>
maskmFile<>
(*"\" -p \""<>tempdir<>parfile<>*)
parfiles<>" > "<>movfold<>"\"output.txt\" \n"<>
copy<>" \n"<>
"exit \n";
RunProcess[$SystemShell,"StandardOutput",command];
]


(* ::Subsubsection::Closed:: *)
(*ElastixCommand*)


ElastixCommand[elastix_,tempdir_,parfile_,{inpfol_,movfol_,outfol_},{fixed_,moving_,out_},{maskf_,maskm_}]:=Block[
{command,inpfold,outfold,movfold,maskfFile,
maskmFile,outfile,parfiles,copy},

inpfold=If[inpfol=="",tempdir,tempdir<>inpfol<>"\\"];
movfold=If[movfol=="",tempdir,tempdir<>movfol<>"\\"];
outfold=If[outfol=="",StringDrop[tempdir,-1],tempdir<>outfol];
outfile=outfold<>"\\"<>out;

maskfFile=If[maskf==="",""," -fMask \""<>tempdir<>maskf<>"\""];
maskmFile=If[maskm==="",""," -mMask \""<>tempdir<>maskm<>"\""];

parfiles=StringJoin[" -p \""<>tempdir<>#<>"\""&/@parfile];
copy=If[out=="","","@ copy \""<>outfold<>"\\result."<>ToString[Length[parfile]-1]<>".nii\" \""<>outfile<>"\""];

command=
"@ \""<>elastix<>
"\" -f \""<>inpfold<>fixed<>
"\" -m \""<>movfold<>moving<>
"\" -out \""<>outfold<>"\""<>
maskfFile<>
maskmFile<>
parfiles<>" > \""<>movfold<>"output.txt\" \n"<>
copy<>" \n";

{command,outfile}
]


(* ::Subsubsection::Closed:: *)
(*RunBatfile*)


RunBatfile[tempdir_,command_]:=Block[{batfile},
batfile=tempdir<>"elastix-batch.bat";
Export[batfile,StringJoin[command],"TEXT"];
RunProcess[$SystemShell, "StandardOutput", "\"" <> batfile <> "\"\n exit \n"];
]


(* ::Subsubsection::Closed:: *)
(*StringPad*)


StringPad[x_] := 
 StringJoin[
  PadLeft[{ToString[x]}, 5 - StringLength[ToString[x]], "0"]
]


(* ::Subsubsection::Closed:: *)
(*ConcatenateTransformFiles*)


ConcatenateTransformFiles[files_, outDir_] := Module[{},
  len = Range[Length[files]];
  filesi = Import[#, "Lines"] & /@ files;
  (
     tfile = 
      If[# == 1, "NoInitialTransform", 
       outDir <> "\\FinalTransform." <> ToString[# - 2] <> ".txt"];
     filesi[[#, 4]] = 
      "(InitialTransformParametersFileName \"" <> tfile <> "\")";
     Export[
      outDir <> "\\FinalTransform." <> ToString[# - 1] <> ".txt", 
      filesi[[#]]];
     ) & /@ len;
  ]


(* ::Subsubsection::Closed:: *)
(*FindTransformix*)


FindTransformix[] := 
 Module[{fil1, fil2}, 
  fil1 = $UserBaseDirectory <> 
    "\\Applications\\DTITools\\Applications\\transformix.exe";
  fil2 = $BaseDirectory <> 
    "\\Applications\\DTITools\\Applications\\transformix.exe";
  If[FileExistsQ[fil1], fil1, If[FileExistsQ[fil2], fil2, "error"]]
  ]


(* ::Subsubsection::Closed:: *)
(*RunBatfileT*)


RunBatfileT[tempdir_, command_] := Block[{batfile},
  batfile = tempdir <> "\\transformix-batch.bat";
  Export[batfile, StringJoin[command], "TEXT"];
  RunProcess[$SystemShell, "StandardOutput", batfile <> "\n exit \n"];
  ]


(* ::Subsubsection::Closed:: *)
(*TransformixCommand*)


TransformixCommand[tempDir_] := Block[{volDirs, transformix},
  transformix = FindTransformix[];
  volDirs = FileNames["vol*", tempDir, 1];
  (
     "@ \"" <> transformix <>
      "\" -in \"" <> First[FileNames["moving*", #]] <>
      "\" -out \"" <> # <>
      "\" -tp \"" <> Last[FileNames["FinalTransform*", #]] <> "\"" <>
      " > \"" <> # <> "\\outputa.txt\" \n" <>
      "@ rename \"" <> # <> "\\result.nii\" resultA-3D.nii \n"
     ) & /@ volDirs
  ]


(* ::Subsection:: *)
(*ReadTransformParameters*)


SyntaxInformation[ReadTransformParameters]={"ArgumentsPattern"->{_}};

ReadTransformParameters[dir_] := Block[{files,filenum,cor},
  files = FileNames["TransformParameters*", dir, 2];
  filenum = 
   ToExpression[
      First[StringCases[FileNameSplit[#][[-2]], 
        DigitCharacter ..]]] & /@ files;
  files = files[[Ordering[filenum]]];
  cor =  
    Partition[
        ToExpression[
         StringSplit[StringTake[Import[#, "Lines"][[3]], {2, -2}]][[
          2 ;;]]], 3][[{1, 4, 3, 2}, {2, 1, 3}]] & /@ files;
  cor[[All, 1]] = cor[[All, 1]]/Degree;
  Flatten /@ cor
  ]


(* ::Subsection:: *)
(*RegisterData*)


(* ::Subsubsection::Closed:: *)
(*RegisterData*)


Options[RegisterData]={
Iterations->1000,
Resolutions->1,
HistogramBins->32,
NumberSamples->2000,
InterpolationOrderReg->1,
BsplineSpacing->30,
BsplineDirections->{1,1,1},
AffineDirections->{1,1,1},
MethodReg->"affine",
OutputImage->True,
TempDirectory->"Default",
DeleteTempDirectory->True,
PrintTempDirectory->True,
OutputTransformation->False
};

SyntaxInformation[RegisterData]={"ArgumentsPattern"->{_,_.,OptionsPattern[]}};


(* ::Subsubsection::Closed:: *)
(*RegisterData Series*)


(*series have no target defninition*)
(*register series of data sets, no vox definition, no mask definition*)
RegisterData[series_?ArrayQ,opts:OptionsPattern[]]:=RegisterData[{series,{1,1,1}},opts]
(*register series of data sets, vox definition, no mask definition*)
RegisterData[{series_?ArrayQ,vox:{_?NumberQ,_?NumberQ,_?NumberQ}},opts:OptionsPattern[]]:=RegisterData[{series,{1},vox},opts]
(*register series of data sets, no vox definition, mask definition*)
RegisterData[{series_?ArrayQ,mask_?ArrayQ},opts:OptionsPattern[]]:=RegisterData[{series,mask,{1,1,1}},opts]

(*register series of data sets, vox definition, mask definition, no target definition*)
RegisterData[{series_?ArrayQ,mask_?ArrayQ,vox:{_?NumberQ,_?NumberQ,_?NumberQ}},opts:OptionsPattern[]]:=Module[
{depthS,error,dim,dimm,dimL,target,moving,dataout,
voxL,output,cyclyc,maskf,maskm},

(*set error*)
error=False;

(*get data properties*)
depthS=ArrayDepth[series];
dim=Dimensions[series];
dimL=If[depthS==3,dim[[1]],dim[[2]]];
dimm=Dimensions[mask];
voxL=Length[vox];

cyclyc=OptionValue[MethodReg]==="cyclyc";

(*check dimensions*)
(*series must be 3 of 4D*)
If[!(depthS==3||depthS==4),Message[RegisterData::dims,depthS];Return[Message[DiffusionReg::fatal]]];
(*sereis must have 2 or more volumes*)
If[!dimL>=2,Message[RegisterData::vol,depthS,dim[[1]]];Return[Message[DiffusionReg::fatal]]];

(*check voxel sizes*)
If[voxL!=3||!(NumberQ@Total@vox),Message[RegisterData::voxs,vox];Return[Message[DiffusionReg::fatal]]];

(*check mask*)
If[mask!={1},If[cyclyc,
(*cyclyc mask needs to be same dimensions as moving data*)
If[dim!=dimm,Message[RegisterData::mask,dimm,dim];Return[Message[DiffusionReg::fatal]]],
If[depthS==3,
(*normal mask, one mask for all or one mask per volume*)
If[!(dim[[2;;3]]==dimm||dim==dimm),Message[RegisterData::mask,dimm,dim];Return[Message[DiffusionReg::fatal]]],
If[!(dim[[{1,3,4}]]==dimm||dim==dimm),Message[RegisterData::mask,dimm,dim];Return[Message[DiffusionReg::fatal]]]
]
]];

(*check if method is cyclyc*)
If[cyclyc,
(*cyclyc series*)
(*define moving and target voluems*)
target=moving=series;

(*go to registration function*)
output=RegisterDatai[{target,{1},vox},{moving,mask,vox},"cyclyc",opts];
output
,
(*normal series*)
(*define moving and target voluems*)
{target,moving}=If[depthS==3,
{series[[1]],series[[2;;]]},
{series[[All,1]],Transpose@series[[All,2;;]]}
];

{maskf,maskm}=If[dimm==dim,If[depthS==3,{mask[[1]],mask[[2;;]]},{mask[[All,1]],Transpose@mask[[All,2;;]]}],{mask,mask}];

(*go to registration function*)
output=RegisterDatai[{target,maskf,vox},{moving,maskm,vox},"series",opts];

If[OptionValue[OutputTransformation],
		(*output data with tranformation parameters*)
		dataout=Prepend[output[[1]],target];
		{If[depthS==4,Transpose@dataout,dataout],Prepend[output[[2]],{0,0,0,0,0,0,1,1,1,0,0,0}]}
		,
		(*output dat without transformation parameters*)
		dataout=Prepend[output,target];
		If[depthS==4,Transpose@dataout,dataout]
]
]
]


(* ::Subsubsection::Closed:: *)
(*RegisterData Volumes*)


(*Volumes do have target defninition*)

(*register two data sets, vox definition and mask definition*)
RegisterData[
{target_?ArrayQ,maskt:{_?ListQ..},voxt:{_?NumberQ,_?NumberQ,_?NumberQ}},
{moving_?ArrayQ,maskm:{_?ListQ..}}
,opts:OptionsPattern[]]:=RegisterData[{target,maskt,voxt},{moving,maskm,{1,1,1}},opts];
RegisterData[
{target_?ArrayQ,maskt:{_?ListQ..}},
{moving_?ArrayQ,maskm:{_?ListQ..},voxm:{_?NumberQ,_?NumberQ,_?NumberQ}}
,opts:OptionsPattern[]]:=RegisterData[{target,maskt,{1,1,1}},{moving,maskm,voxm},opts];

(*register two data sets, vox definition and maskt definition*)
RegisterData[
{target_?ArrayQ,maskt:{_?ListQ..},voxt:{_?NumberQ,_?NumberQ,_?NumberQ}},
moving_?ArrayQ
,opts:OptionsPattern[]]:=RegisterData[{target,maskt,voxt},{moving,{1},{1,1,1}},opts];
RegisterData[
{target_?ArrayQ,maskt:{_?ListQ..}},
{moving_?ArrayQ,voxm:{_?NumberQ,_?NumberQ,_?NumberQ}}
,opts:OptionsPattern[]]:=RegisterData[{target,maskt,{1,1,1}},{moving,{1},voxm},opts];
RegisterData[
{target_?ArrayQ,maskt:{_?ListQ..},voxt:{_?NumberQ,_?NumberQ,_?NumberQ}},
{moving_?ArrayQ,voxm:{_?NumberQ,_?NumberQ,_?NumberQ}}
,opts:OptionsPattern[]]:=RegisterData[{target,maskt,voxt},{moving,{1},voxm},opts];

(*register two data sets, vox definition and maskm definition*)
RegisterData[
{target_?ArrayQ,voxt:{_?NumberQ,_?NumberQ,_?NumberQ}},
{moving_?ArrayQ,maskm:{_?ListQ..}}
,opts:OptionsPattern[]]:=RegisterData[{target,{1},voxt},{moving,maskm,{1,1,1}},opts];
RegisterData[
target_?ArrayQ,
{moving_?ArrayQ,maskm:{_?ListQ..},voxm:{_?NumberQ,_?NumberQ,_?NumberQ}}
,opts:OptionsPattern[]]:=RegisterData[{target,{1},{1,1,1}},{moving,maskm,voxm},opts];
RegisterData[
{target_?ArrayQ,voxt:{_?NumberQ,_?NumberQ,_?NumberQ}},
{moving_?ArrayQ,maskm:{_?ListQ..},voxm:{_?NumberQ,_?NumberQ,_?NumberQ}}
,opts:OptionsPattern[]]:=RegisterData[{target,{1},voxt},{moving,maskm,voxm},opts];

(*register two data sets, no vox definition and mask definition*)
RegisterData[
{target_?ArrayQ,maskt_:{_?ListQ..}},
moving_?ArrayQ
,opts:OptionsPattern[]]:=RegisterData[{target,maskt,{1,1,1}},{moving,{1},{1,1,1}},opts];
RegisterData[
target_?ArrayQ,
{moving_?ArrayQ,maskm:{_?ListQ..}}
,opts:OptionsPattern[]]:=RegisterData[{target,{1},{1,1,1}},{moving,maskm,{1,1,1}},opts];
RegisterData[
{target_?ArrayQ,maskt:{_?ListQ..}},
{moving_?ArrayQ,maskm:{_?ListQ..}}
,opts:OptionsPattern[]]:=RegisterData[{target,maskt,{1,1,1}},{moving,maskm,{1,1,1}},opts];

(*register two data sets, vox definition and no mask definition*)
RegisterData[
{target_?ArrayQ,voxt:{_?NumberQ,_?NumberQ,_?NumberQ}},
moving_?ArrayQ
,opts:OptionsPattern[]]:=RegisterData[{target,{1},voxt},{moving,{1},{1,1,1}},opts]
RegisterData[
target_?ArrayQ,
{moving_?ArrayQ,voxm:{_?NumberQ,_?NumberQ,_?NumberQ}}
,opts:OptionsPattern[]]:=RegisterData[{target,{1},{1,1,1}},{moving,{1},voxm},opts]
RegisterData[
{target_?ArrayQ,voxt:{_?NumberQ,_?NumberQ,_?NumberQ}},
{moving_?ArrayQ,voxm:{_?NumberQ,_?NumberQ,_?NumberQ}}
,opts:OptionsPattern[]]:=RegisterData[{target,{1},voxt},{moving,{1},voxm},opts]

(*register two data sets, no vox definition and no mask definition*)
RegisterData[
target_?ArrayQ,
moving_?ArrayQ
,opts:OptionsPattern[]]:=RegisterData[{target,{1},{1,1,1}},{moving,{1},{1,1,1}},opts]

(*register two data sets, mask and vox definition*)
RegisterData[
{target_?ArrayQ,maskt_?ArrayQ,voxt:{_?NumberQ,_?NumberQ,_?NumberQ}},
{moving_?ArrayQ,maskm_?ArrayQ,voxm:{_?NumberQ,_?NumberQ,_?NumberQ}},opts:OptionsPattern[]]:=Module[
{depthT,depthM,voxtL,voxmL,error,dim,type,mov,output},

(*set error*)
error=False;

(*Check Method, cyclyc only possible for series*)
If[OptionValue[MethodReg]==="cyclyc",error=True;Message[RegisterData::metc];];

(*get data properties*)
depthT=ArrayDepth[target];
depthM=ArrayDepth[moving];
dim=Dimensions[moving];
voxtL=Length[voxt];
voxmL=Length[voxm];

(*check dimensions and determine type*)
(*2D-2D, 3D-3D*)
type=If[depthT==depthM,
"vol",
(*2D-3D, 3D-4D*)
If[(depthT==2||depthT==3)&&depthM==depthT+1,
"series",
(*error*)
error=True;Message[RegisterData::dim,depthT,depthM];
]
];

(*check voxel sies*)
If[voxtL!=3||voxmL!=3||!(NumberQ@Total@voxt)||!(NumberQ@Total@voxm),Message[RegisterData::vox,voxt,voxm];Return[Message[DiffusionReg::fatal]]];

(*if error found quit*)
If[error,Return[Message[DiffusionReg::fatal]]];

(*define moving voluems*)
mov=If[depthM==4,Transpose@moving,moving];

(*go to registration function*)
output=RegisterDatai[{target,maskt,voxt},{mov,maskm,voxm},type,opts];

If[OptionValue[OutputTransformation],
		{If[depthM==4,Transpose@output[[1]],output[[1]]],Prepend[output[[2]],{0,0,0,0,0,0,1,1,1,0,0,0}]},
		If[depthM==4,Transpose@output,output]
]
]


(* ::Subsubsection::Closed:: *)
(*RegisterDatai*)


Options[RegisterDatai]=Options[RegisterData];

RegisterDatai[{target_?ArrayQ,voxt:{_?NumberQ,_?NumberQ,_?NumberQ}},{moving_?ArrayQ,voxm:{_?NumberQ,_?NumberQ,_?NumberQ}},type_,opts:OptionsPattern[]]:=
RegisterDatai[{target,{1},voxt},{moving,{1},voxm},type,opts]

RegisterDatai[{target_?ArrayQ,maskt_,voxt:{_?NumberQ,_?NumberQ,_?NumberQ}},{moving_?ArrayQ,voxm:{_?NumberQ,_?NumberQ,_?NumberQ}},type_,opts:OptionsPattern[]]:=
RegisterDatai[{target,maskt,voxt},{moving,{1},voxm},type,opts]

RegisterDatai[{target_?ArrayQ,voxt:{_?NumberQ,_?NumberQ,_?NumberQ}},{moving_?ArrayQ,maskm_,voxm:{_?NumberQ,_?NumberQ,_?NumberQ}},type_,opts:OptionsPattern[]]:=
RegisterDatai[{target,{1},voxt},{moving,maskm,voxm},type,opts]

RegisterDatai[
{target_?ArrayQ,maskt_?ArrayQ,voxt:{_?NumberQ,_?NumberQ,_?NumberQ}},{moving_?ArrayQ,maskm_?ArrayQ,voxm:{_?NumberQ,_?NumberQ,_?NumberQ}},
type_,OptionsPattern[]]:=Module[
{tdir,tempdir,elastix,targetFile,parstring,
outputImg,iterations,resolutions,histogramBins,numberSamples,derivativeScaleA,derivativeScaleB,
interpolationOrder,method,bsplineSpacing,data,vox,
dimmov,dimtar,dimmovm,dimtarm,
inpfol,movfol,outfol,fixedF,movingF,outF,parF,depth,index,
error,regpars,lenMeth,command,outfile,fmaskF,mmaskF,maske,maske2,w},

w={{0,0,0,0,0,0,1,1,1,0,0,0}};

(*set error*)
error=False;
maske=False;

(*get option values*)
tdir=OptionValue[TempDirectory];
outputImg=ToLowerCase[ToString[OptionValue[OutputImage]]];

method=OptionValue[MethodReg];
(*Print[method];*)

bsplineSpacing=OptionValue[BsplineSpacing];
bsplineSpacing=If[!ListQ[bsplineSpacing],ConstantArray[bsplineSpacing,3],bsplineSpacing];
derivativeScaleB=OptionValue[BsplineDirections];
derivativeScaleA=OptionValue[AffineDirections];

(*Print[{derivativeScaleA,derivativeScaleB}];*)

iterations=OptionValue[Iterations];
resolutions=OptionValue[Resolutions];
histogramBins=OptionValue[HistogramBins];
numberSamples=OptionValue[NumberSamples];
interpolationOrder=OptionValue[InterpolationOrderReg];
regpars={iterations,resolutions,histogramBins,numberSamples,interpolationOrder};

dimmov=Dimensions[moving];
dimtar=Dimensions[target];
dimmovm=Dimensions[maskm];
dimtarm=Dimensions[maskt];

(*find the elastix program*)
elastix=FindElastix[];
If[elastix=="error",error=True;Message[RegisterData::elastix];];

(*create temp directory*)
tdir=(If[StringQ[tdir],tdir,"Default"]/. {"Default"->$TemporaryDirectory});

tdir=If[Last[FileNameSplit[tdir]] === "DTItoolsReg" || Last[FileNameSplit[tdir]] === "anat",
	tdir,tdir<>"\\DTItoolsReg"
];

If[DirectoryQ[tdir],DeleteDirectory[tdir,DeleteContents->True]];
tempdir=CreateDirectory[tdir]<>"\\";
If[!DirectoryQ[tempdir],Message[RegisterData::dir];Return[Message[DiffusionReg::fatal]]];

(*check registration method*)
method=If[StringQ[method],{method},method];
If[!MemberQ[{"rigid","affine","rigidDTI","affineDTI","bspline","cyclyc"},#],
	Message[RegisterData::met,#];
	Return[Message[DiffusionReg::fatal]]
	]&/@method; 
lenMeth=Length[method];

(*only cyclyc is possible*)
If[MemberQ[method,"cyclyc"]&&lenMeth>1,error=True];

(*create parameter list*)
regpars=If[NumberQ[#],ConstantArray[#,lenMeth],
If[Length[#]==lenMeth,#,Message[RegisterData::par,#,lenMeth];Return[Message[DiffusionReg::fatal]];
]]&/@regpars;

(*check mask dimensions*)

(*if error quit*)
If[error,Return[Message[RegisterData::fatal]]];
If[OptionValue[PrintTempDirectory],PrintTemporary["using as temp directory: "<>tdir]];

(*create parameter files*)
parF=MapThread[(
parstring=ParString[#2,{#1,outputImg},bsplineSpacing,derivativeScaleB,derivativeScaleA];
parF="parameters-"<>#1<>".txt";
Export[tempdir<>parF,parstring];
parF
)&,{method,Transpose[regpars]}];

(*create target file*)
depth=If[type==="cyclyc",ToString[ArrayDepth[target]-1]<>"D-t",ToString[ArrayDepth[target]]<>"D"];
fixedF="target-"<>depth<>".nii";
targetFile=tempdir<>fixedF;

ExportNii[target,voxt,targetFile];

(*perform registration*)
Switch[type,

"vol",
{inpfol,movfol,outfol}={"","",""};
{movingF,outF}={"moving-"<>depth<>".nii","result-"<>depth<>".nii"};
ExportNii[moving,voxm,tempdir<>movingF];

{fmaskF,mmaskF}={"",""};

(*check if target mask is needed*)
If[dimtarm == dimtar && maskt!={1},
	fmaskF="targetMask.nii";
	ExportNii[maskt,voxm,tempdir<>fmaskF]];

(*check if moving mask is needed*)
If[(dimmovm == dimmov && maskm!={1}),
	mmaskF=movfol<>"\\"<>"moveMask.nii";
	ExportNii[maskm,voxm,tempdir<>mmaskF]];

RunElastix[elastix,tempdir,parF,{inpfol,movfol,outfol},{fixedF,movingF,outF},{fmaskF,mmaskF}];
{data,vox}=ImportNii[tempdir<>outfol<>outF];
,

"cyclyc",
{inpfol,movfol,outfol}={"","",""};
{fmaskF,mmaskF}={"",""};
{movingF,outF}={"moving-"<>depth<>".nii","result-"<>depth<>".nii"};
ExportNii[moving,voxm,tempdir<>movingF];
If[maskm!={1},mmaskF="movemask.nii";
ExportNii[maskm,voxm,tempdir<>mmaskF];
];
RunElastix[elastix,tempdir,parF,{inpfol,movfol,outfol},{fixedF,movingF,outF},{fmaskF,mmaskF}];
{data,vox}=ImportNii[tempdir<>outfol<>outF];
,

"series",
DynamicModule[{i},
inpfol="";
{fmaskF,mmaskF}={"",""};
{movingF,outF}={"moving-"<>depth<>".nii","result-"<>depth<>".nii"};

(*export one mask for every volume in the series*)
If[dimtarm == dimtar && maskt!={1},
fmaskF="targetMask.nii";
ExportNii[maskt,voxm,tempdir<>fmaskF]];

(*check if mask needs to be exported for each volume*)
maske=(dimmovm == dimmov && maskm!={1});
(*check if same mask for all volumes*)
maske2=(dimmovm == Drop[dimmov,1] && maskm!={1});

i=0;

(*export data*)
{command,outfile}=Transpose@(
(
	index=StringPad[#];
	movfol=outfol="vol"<>index;
	CreateDirectory[tempdir<>outfol];
	ExportNii[moving[[#]],voxm,tempdir<>movfol<>"\\"<>movingF];
	
	(*export mask*)
	If[maske,
	mmaskF=movfol<>"\\"<>"movemask.nii";
	ExportNii[maskm[[#]],voxm,tempdir<>mmaskF];
	];
	
	If[maske2,
	mmaskF=movfol<>"\\"<>"movemask.nii";
	ExportNii[maskm,voxm,tempdir<>mmaskF];
	];
	
	ElastixCommand[elastix,tempdir,parF,{inpfol,movfol,outfol},{fixedF,movingF,outF},{fmaskF,mmaskF}]
)&/@Range[Length[moving]]);
(*create and run batch*)
RunBatfile[tempdir,command];

(*Import data*)
data=(First@ImportNii[#])&/@outfile;

If[OptionValue[OutputTransformation],	w=ReadTransformParameters[tempdir]];
];
];

If[OptionValue[DeleteTempDirectory],DeleteDirectory[tempdir,DeleteContents->True]];

(*If[type=="series"&&ArrayDepth[data]==4,data=Transpose[data]];*)

If[OptionValue[OutputTransformation],
	{Clip[data,{0,Infinity}],w},
	Clip[data,{0,Infinity}]
]
]


(* ::Subsection::Closed:: *)
(*RegisterCardiacData*)


Options[RegisterCardiacData]=Join[{RegistrationTarget->"Mean"},Options[RegisterData]];

SyntaxInformation[RegisterCardiacData]={"ArgumentsPattern"->{_,OptionsPattern[]}};

(*data only*)
RegisterCardiacData[data_?ArrayQ,opts:OptionsPattern[]]:=RegisterCardiacData[{data,{1},{1,1,1}},opts]
(*data with voxel*)
RegisterCardiacData[{data_?ArrayQ,vox:{_?NumberQ,_?NumberQ,_?NumberQ}},opts:OptionsPattern[]]:=RegisterCardiacData[{data,{1},vox},opts]
(*data with mask*)
RegisterCardiacData[{data_?ArrayQ,mask_?ArrayQ},opts:OptionsPattern[]]:=RegisterCardiacData[{data,mask,{1,1,1}},opts]
(*data with mask and voxel*)
RegisterCardiacData[{data_?ArrayQ,mask_?ArrayQ,vox:{_?NumberQ,_?NumberQ,_?NumberQ}},opts:OptionsPattern[]]:=Block[
{tdir, datar, slices, maskr},

tdir=OptionValue[TempDirectory];
tdir=(If[StringQ[tdir],tdir,"Default"]/. {"Default"->$TemporaryDirectory})<>"\\DTItoolsReg";
If[OptionValue[PrintTempDirectory],PrintTemporary["using as temp directory: "<>tdir]];

slices=Range[Length[data]];
maskr=If[mask=={1},ConstantArray[1,Dimensions[data[[All,1]]]],mask];

DynamicModule[{i},
i=0;
PrintTemporary@ProgressIndicator[Dynamic[i],{0,Length[data]}];
datar=Switch[
OptionValue[RegistrationTarget],
"Mean",
(i++;RegisterData[{N[Mean@data[[#]]],maskr[[#]],vox},{data[[#]],maskr[[#]],vox},
	OutputTransformation->False,
	PrintTempDirectory->False,FilterRules[{opts},Options[RegisterData]]])&/@slices,
"Median",
(i++;RegisterData[{N[Median@data[[#]]],maskr[[#]],vox},{data[[#]],maskr[[#]],vox},
	OutputTransformation->False,
	PrintTempDirectory->False,FilterRules[{opts},Options[RegisterData]]])&/@slices,
"First",
(i++;RegisterData[{data[[#]],maskr[[#]],vox},
	OutputTransformation->False,
	PrintTempDirectory->False,FilterRules[{opts},Options[RegisterData]]])&/@slices,
"Cyclyc",
Print["ToDo"]
];
];
datar
]


(* ::Subsection::Closed:: *)
(*RegisterDiffusionData*)


Options[RegisterDiffusionData] = 
  Join[Options[RegisterData] /. {{1, 1, 1} -> {0, 1, 1}, "affine" -> "affineDTI", "rigid" -> "rigidDTI"},
   {IterationsA -> 1000, ResolutionsA -> 1, HistogramBinsA -> 32, 
    NumberSamplesA -> 2000, InterpolationOrderRegA -> 1, 
    MethodRegA -> {"rigidDTI", "bspline"},RegistrationTarget->"Fist"}];

SyntaxInformation[RegisterDiffusionData] = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

(*No anatomical data, goto Registerdata*)
RegisterDiffusionData[
	{dtidata_?ArrayQ, vox : {_?NumberQ, _?NumberQ, _?NumberQ}},
	opts : OptionsPattern[]] := RegisterDiffusionData[{dtidata, {1}, vox},opts]

RegisterDiffusionData[
	{dtidata_?ArrayQ, dtimask_?ArrayQ, vox : {_?NumberQ, _?NumberQ, _?NumberQ}},
	opts:OptionsPattern[]] := (
	RegisterData[{dtidata, dtimask, vox},(*OutputTransformation->True,*) 
		MethodReg-> (OptionValue[MethodReg] /. {"affine" -> "affineDTI", "rigid" -> "rigidDTI"}),
		AffineDirections -> {1, 1, 1},
		FilterRules[{opts}, Options[RegisterData]]]
		)

(**)
RegisterDiffusionData[
  {dtidata_?ArrayQ, vox : {_?NumberQ, _?NumberQ, _?NumberQ}},
  {anatdata_?ArrayQ, voxa : {_?NumberQ, _?NumberQ, _?NumberQ}},
  opts : OptionsPattern[]
  ] := RegisterDiffusionData[{dtidata, {1}, vox}, {anatdata, {1},voxa}, opts]

RegisterDiffusionData[
  {dtidata_?ArrayQ, dtimask_?ArrayQ, 
   vox : {_?NumberQ, _?NumberQ, _?NumberQ}},
  {anatdata_?ArrayQ, voxa : {_?NumberQ, _?NumberQ, _?NumberQ}},
  opts : OptionsPattern[]
  ] := RegisterDiffusionData[{dtidata, dtimask, vox}, {anatdata, {1}, voxa}, opts]

RegisterDiffusionData[
  {dtidata_?ArrayQ, vox : {_?NumberQ, _?NumberQ, _?NumberQ}},
  {anatdata_?ArrayQ, anatmask_?ArrayQ, 
   voxa : {_?NumberQ, _?NumberQ, _?NumberQ}},
  vox_, opts : OptionsPattern[]
  ] := RegisterDiffusionData[{dtidata, {1}, vox}, {anatdata, anatmask, voxa}, opts]

RegisterDiffusionData[
  {dtidata_?ArrayQ, dtimask_?ArrayQ, vox : {_?NumberQ, _?NumberQ, _?NumberQ}},
  {anatdata_?ArrayQ, anatmask_?ArrayQ, voxa : {_?NumberQ, _?NumberQ, _?NumberQ}},
  opts : OptionsPattern[]
  ] := Module[{dtidatar, tempDir, tempDira, volDirs, w,
   tFilesA, tFilesD, dtidatarA, cmd, target, movingdata},
  (*Print["RegisterDiffusionData"];*)
  
  (*get the current temp dir and define the anat tempdir*)
  tempDir = OptionValue[TempDirectory];
  tempDir = (If[StringQ[tempDir], tempDir, "Default"]/. {"Default"->$TemporaryDirectory})<>"\\DTItoolsReg";
  tempDira = tempDir <> "\\anat";
  
  (*perform DTI registration*)
  dtidatar = RegisterData[{dtidata, dtimask, vox},
    TempDirectory -> tempDir, 
    DeleteTempDirectory -> False, 
    (*OutputTransformation->True,*) 
    MethodReg-> (OptionValue[MethodReg] /. {"affine" -> "affineDTI", "rigid" -> "rigidDTI"}),
    (*AffineDirections -> {1, 1, 1},*)
    FilterRules[{opts} , Options[RegisterData]]];
  If[OptionValue[OutputTransformation],{dtidatar,w}=dtidata];
  
  target = OptionValue[RegistrationTarget];
  movingdata=If[ListQ[target] && AllTrue[target, IntegerQ] && Min[target] > 0 && Max[target] <= Length[dtidatar[[1]]],
  	Median /@ dtidatar[[All, DeleteDuplicates[target]]],
  	Switch[target,
  		"Median", Median /@ dtidatar,
  		"First", dtidatar[[All, 1]],
  		_, Mean /@ dtidatar
  		]];
  
  (*perform anat registration*)
  RegisterData[{anatdata, anatmask, voxa}, {movingdata, dtimask, vox},
   TempDirectory -> tempDira, 
   DeleteTempDirectory -> False,
   Iterations -> OptionValue[IterationsA], 
   Resolutions -> OptionValue[ResolutionsA],
   HistogramBins -> OptionValue[HistogramBinsA], 
   NumberSamples -> OptionValue[NumberSamplesA],
   InterpolationOrderReg -> OptionValue[InterpolationOrderRegA],
   BsplineSpacing -> OptionValue[BsplineSpacing], 
   BsplineDirections -> OptionValue[BsplineDirections],
   AffineDirections -> OptionValue[AffineDirections],
   MethodReg -> OptionValue[MethodRegA], 
   FilterRules[{opts}, Options[RegisterData]]
   ];
  
  (*transform all diffusion files to anatomy*)
  
  (*export diffusion reg target*)
  CreateDirectory[tempDir<>"\\vol0000"];
  ExportNii[dtidatar[[All,1]],vox,tempDir<>"\\vol0000\\moving-3D.nii"];
  
  (*get vol folders and anat transform files*)
  volDirs = FileNames["vol*", tempDir, 1];
  tFilesA = FileNames["TransformParameters*", tempDira];
  
  (*create Final Transform files*)
  (
     tFilesD = FileNames["TransformParameters*", #];
     ConcatenateTransformFiles[Join[tFilesD, tFilesA], #]
     ) & /@ volDirs;
  
  (*call transformix*)
  cmd = TransformixCommand[tempDir];
  PrintTemporary["Combining transformations"];
  RunBatfileT[tempDir, cmd];
  
  (*import dti data in anat space*)
  dtidatarA = Transpose[(ImportNii[#][[1]]) & /@ FileNames["resultA*", tempDir, 2]];
  
  (*finalize by deleting temp director*)
  If[OptionValue[DeleteTempDirectory],DeleteDirectory[tempDir,DeleteContents->True]];
  
  (*output data*)
  If[OptionValue[OutputTransformation],
  	{Clip[dtidatar,{0,Infinity}], Clip[dtidatarA,{0,Infinity}], w},
  	Clip[{dtidatar, dtidatarA},{0,Infinity}]
  ]
]


(* ::Subsection::Closed:: *)
(*RegisterDataSplit*)

Options[RegisterDataSplit] := Options[RegisterDiffusionData];

SyntaxInformation[RegisterDataSplit] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

RegisterDataSplit[data_, vox: {_?NumberQ, _?NumberQ, _?NumberQ}, opts : OptionsPattern[]] := 
  Block[{datal, datar},
   {datal, datar} = CutData[data];
   datal = RegisterDiffusionData[{datal, vox}, opts];
   datar = RegisterDiffusionData[{datar, vox}, opts];
   StichData[datal, datar]
   ];

RegisterDataSplit[{data_, vox: {_?NumberQ, _?NumberQ, _?NumberQ}}, {dataa_, voxa: {_?NumberQ, _?NumberQ, _?NumberQ}}, 
   opts : OptionsPattern[]] := Block[{datal, datar, dataal, dataar},
   {datal, datar} = CutData[data];
   {dataal, dataar} = CutData[dataa];
   datal = 
    RegisterDiffusionData[{datal, vox}, {dataal, voxa}, opts][[2]];
   datar = 
    RegisterDiffusionData[{datar, vox}, {dataar, voxa}, opts][[2]];
   StichData[datal, datar]
   ];

RegisterDataSplit[{data_, mask_, vox: {_?NumberQ, _?NumberQ, _?NumberQ}}, {dataa_, maska_, voxa: {_?NumberQ, _?NumberQ, _?NumberQ}}, 
   opts : OptionsPattern[]] := Block[
   {datal, datar, dataal, dataar, maskl, maskr, maskal, maskar},
   {datal, datar} = CutData[data];
   {maskl, maskr} = CutData[mask];
   {dataal, dataar} = CutData[dataa];
   {maskal, maskar} = CutData[maska];

   datal = 
    RegisterDiffusionData[{datal, maskl, vox}, {dataal, maskal, voxa},
       opts][[2]];
   datar = 
    RegisterDiffusionData[{datar, maskr, vox}, {dataar, maskar, voxa},
       opts][[2]];
   
   StichData[datal, datar]
   ];


(* ::Subsection::Closed:: *)
(*CorrectBmatrix*)


Options[CorrectBmatrix] = {MethodReg -> "Full"}

SyntaxInformation[CorrectBmatrix] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};
 
 CorrectBmatrix[bmati_, w_,OptionsPattern[]] := 
  Block[{bmat, trans, bmi, rot, bm, bmnew, bminew},
   bmat = If[Length[First[bmati]] == 7, BmatrixConv[bmati], bmati];
   MapThread[(
      trans = #1;
      bmi = #2;
      rot = ParametersToTransform[trans, OptionValue[MethodReg]];
      bm = TensMat[(bmi/{1, 1, 1, 2, 2, 2})[[{2, 1, 3, 4, 6, 5}]]];
      bmnew = rot.bm.Transpose[rot];
      
      (*Print[MatrixForm/@Round[{bm,bmnew,rot},.00001]];*)
      bminew = ({1, 1, 1, 2, 2, 2} TensVec[bmnew]
      )[[{2, 1, 3, 4, 6, 5}]]
      ) &, {w, bmat}]
   ]


(* ::Subsection::Closed:: *)
(*CorrectGradients*)


Options[CorrectGradients] = {MethodReg -> "Rotation"}

SyntaxInformation[CorrectGradients] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};
 
 CorrectGradients[grad_, w_,OptionsPattern[]] := 
  Block[{gr,grnew,trans,rot},
   MapThread[(
      ParametersToTransform[#1, OptionValue[MethodReg]].#2
      ) &, {w, grad}]
   ]


(* ::Subsection::Closed:: *)
(*ParametersToTransform*)


ParametersToTransform[w_, opt_] := 
 Block[{tx, ty, tz, rx, ry, rz, sx, sy, sz, gx, gy, gz, T, R, G, S, 
   Rx, Ry, Rz, Gx, Gy, Gz, mat, mats, matL},
  {rx, ry, rz, tx, ty, tz, sx, sy, sz, gx, gy, gz} = w;
  {{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}};
  rx = rx Degree; ry = ry Degree; rz = rz Degree;
  T = {
    {1, 0, 0, tx},
    {0, 1, 0, ty},
    {0, 0, 1, tz},
    {0, 0, 0, 1}};
  Rx = {
    {1, 0, 0, 0},
    {0, Cos[rx], Sin[rx], 0},
    {0, -Sin[rx], Cos[rx], 0},
    {0, 0, 0, 1}};
  Ry = {
    {Cos[ry], 0, -Sin[ry], 0},
    {0, 1, 0, 0},
    {Sin[ry], 0, Cos[ry], 0},
    {0, 0, 0, 1}};
  Rz = {
    {Cos[rz], Sin[rz], 0, 0},
    {-Sin[rz], Cos[rz], 0, 0},
    {0, 0, 1, 0},
    {0, 0, 0, 1}};
  R = Rx.Ry.Rz;
  Gx = {
    {1, 0, gx, 0},
    {0, 1, 0, 0},
    {0, 0, 1, 0},
    {0, 0, 0, 1}};
  Gy = {
    {1, 0, 0, 0},
    {gy, 1, 0, 0},
    {0, 0, 1, 0},
    {0, 0, 0, 1}};
  Gz = {
    {1, 0, 0, 0},
    {0, 1, 0, 0},
    {0, gz, 1, 0},
    {0, 0, 0, 1}};
  G = Gx.Gy.Gz;
  S = {
    {sx, 0, 0, 0},
    {0, sy, 0, 0},
    {0, 0, sz, 0},
    {0, 0, 0, 1}};
  
  mat = Switch[opt,
    "Full", T.R.G.S,
    "Rotation", R,
    _, R
    ];
  
  mats = mat[[1 ;; 3, 1 ;; 3]];
  
  (MatrixPower[mats.Transpose[mats], -(1/2)].mats)
  ]

(* ::Section:: *)
(*End Package*)


End[]

SetAttributes[#,{Protected, ReadProtected}]&/@ Names["DTITools`ElastixTools`*"];

EndPackage[]