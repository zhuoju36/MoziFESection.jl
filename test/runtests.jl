include("../src/MoziFESection.jl")

using .MoziFESection

sec=BeamSection(1,1,1,1,1,1,1,1,1,1)
sec=ISection(1,1,400,200,200,10,20,20)
sec=HSection(1,1,200,200,10,10)
sec=BoxSection(1,1,200,200,10,10)
sec=PipeSection(1,1,400,20)
sec=CircleSection(1,1,400)