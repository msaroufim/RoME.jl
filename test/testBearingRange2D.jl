using RoME
using Statistics
# , Distributions
using Test

import Base: convert

##

@testset "test sampling from BearingRange factor..." begin

##

p2br = Pose2Point2BearingRange(Normal(0,0.1),Normal(20.0,1.0))

fg = initfg()
addVariable!(fg, :x0, Pose2)
addVariable!(fg, :x1, Point2)
addFactor!(fg, [:x0;:x1], p2br, graphinit=false)

meas = sampleFactor(IIF._getCCW(fg, :x0x1f1), 100)

##

# meas = getSample(p2br, 100)
@test abs(Statistics.mean(meas[1][1,:])) < 0.1
@test 0.05 < abs(Statistics.std(meas[1][1,:])) < 0.2

@test abs(Statistics.mean(meas[1][2,:]) - 20.0) < 1.0
@test 0.5 < abs(Statistics.std(meas[1][2,:])) < 1.5

##

end


@testset "test BearingRange factor residual function..." begin

##

# dummy variables
fg = initfg()
X0 = addVariable!(fg, :x0, Pose2)
X1 = addVariable!(fg, :x1, Point2)

##

p2br = Pose2Point2BearingRange(Normal(0,0.1),Normal(20.0,1.0))

xi = zeros(3)
li = zeros(2); li[1] = 20.0;
zi = (zeros(2),); zi[1][2] = 20.0


res = testFactorResidualBinary( p2br, 
                                Pose2, 
                                Point2, 
                                xi, 
                                li, 
                                zi )
#

@show res
@test norm(res) < 1e-14

##

xi = zeros(3)
li = zeros(2); li[2] = 20.0;
zi = (zeros(2),); zi[1][:] = [pi/2;20.0]

# idx = 1
# res = zeros(2)
# p2br(res, fmd, idx, zi, xi, li)

res = testFactorResidualBinary( p2br, 
                                Pose2, 
                                Point2, 
                                xi, 
                                li, 
                                zi )

@show res
@test norm(res) < 1e-14


xi = zeros(3); xi[3] = pi/2
li = zeros(2); li[2] = 20.0;
zi = (zeros(2),); zi[1][:] = [0.0;20.0]


res = testFactorResidualBinary( p2br, 
                                Pose2, 
                                Point2, 
                                xi, 
                                li, 
                                zi )
#
@show res
@test norm(res) < 1e-14

##

xi = zeros(3); xi[3] = -pi/2
li = zeros(2); li[1] = 20.0;
# zi = ([0.0;pi/2],[0.0;20.0],)
zi = (zeros(2),); zi[1][:] = [pi/2;20.0]

# idx = 2
# res = zeros(2)
# p2br(res, fmd, idx, zi, xi, li)

res = testFactorResidualBinary( p2br, 
                                Pose2, 
                                Point2, 
                                xi, 
                                li, 
                                zi )


@show res
@test norm(res) < 1e-14

##
# #TODO Update to new CalcFactor 
# # test parametric Pose2Point2BearingRange
# f = Pose2Point2BearingRange(Normal(0.0,1), Normal(10.0,1))
# @test isapprox(f([0.,0,0], [10.,0]), 0, atol = 1e-9)
# @test isapprox(f([0,0,pi/2], [0.,10]), 0, atol = 1e-9)

# f = Pose2Point2BearingRange(Normal(pi/2,1), Normal(10.0,1))
# @test isapprox(f([0.,0,0], [0.,10]), 0, atol = 1e-9)
# @test isapprox(f([0,0,pi/2], [-10.,0]), 0, atol = 1e-9)

# f = Pose2Point2BearingRange(Normal(pi,1), Normal(10.0,1))
# @test isapprox(f([0.,0,0], [-10.,0]), 0, atol = 1e-9)
# @test isapprox(f([0,0,pi/2], [0.,-10]), 0, atol = 1e-9)

# f = Pose2Point2BearingRange(Normal(-pi/2,1), Normal(10.0,1))
# @test isapprox(f([0.,0,0], [0.,-10]), 0, atol = 1e-9)
# @test isapprox(f([0,0,pi/2], [10.,0]), 0, atol = 1e-9)

end




@testset "test unimodal bearing range factor, solve for landmark..." begin

##

# Start with an empty graph
N = 1
fg = initfg()

#add pose with partial constraint
addVariable!(fg, :x0, Pose2)
addFactor!(fg, [:x0], PriorPose2(MvNormal(zeros(3), 0.01*Matrix{Float64}(LinearAlgebra.I, 3,3))), graphinit=false)
# force particular initialization
setVal!(fg, :x0, zeros(3,1))

##----------- sanity check that predictbelief plumbing is doing the right thing
pts, = predictbelief(fg, :x0, ls(fg, :x0), N=75)
@test sum(abs.(Statistics.mean(pts,dims=2)) .< [0.1; 0.1; 0.1]) == 3
@test sum([0.05; 0.05; 0.05] .< Statistics.std(pts,dims=2) .< [0.15; 0.15; 0.15]) == 3
#------------

# Add landmark
addVariable!(fg, :l1, Point2, tags=[:LANDMARK;])
li = zeros(2,1); li[1,1] = 20.0;
setVal!(fg, :l1, li)


# Add bearing range measurement between pose and landmark
p2br = Pose2Point2BearingRange(Normal(0,0.1),Normal(20.0,1.0))
addFactor!(fg, [:x0; :l1], p2br, graphinit=false)

# there should be just one (the bearingrange) factor connected to :l1
@test length(ls(fg, :l1)) == 1
# drawGraph(fg, show=true)

# check the forward convolution is working properly
pts, = predictbelief(fg, :l1, ls(fg, :l1), N=75)
@test sum(abs.(Statistics.mean(pts,dims=2) - [20.0; 0.0]) .< [2.0; 2.0]) == 2
@test sum([0.1; 0.1] .< Statistics.std(pts,dims=2) .< [3.0; 3.0]) == 2

# using Gadfly, KernelDensityEstimate, KernelDensityEstimatePlotting
#
# pl = plotKDE(kde!(pts))
# pl.coord = Coord.Cartesian(xmin=-5,xmax=25, ymin=-10.0,ymax=10)
# pl

##

end


@testset "test unimodal bearing range factor, solve for pose..." begin

##

# Start with an empty graph
N = 1
fg = initfg()

# Add landmark
addVariable!(fg, :l1, Point2, tags=[:LANDMARK;])
addFactor!(fg, [:l1], PriorPoint2(MvNormal([20.0;0.0], Matrix(Diagonal([1.0;1.0].^2)))),  graphinit=false ) # could be IIF.Prior
li = zeros(2,1); li[1,1] = 20.0;
setVal!(fg, :l1, li)

#add pose with partial constraint
addVariable!(fg, :x0, Pose2)
# force particular initialization
setVal!(fg, :x0, zeros(3,1))

# Add bearing range measurement between pose and landmark
p2br = Pose2Point2BearingRange(Normal(0,0.1),Normal(20.0,1.0))
addFactor!(fg, [:x0; :l1], p2br, graphinit=false)

# there should be just one (the bearingrange) factor connected to :l1
@test length(ls(fg, :x0)) == 1
# writeGraphPdf(fg)

# check the forward convolution is working properly
pts, = predictbelief(fg, :x0, ls(fg, :x0), N=75)

pts[3,:] .= TU.wrapRad.(pts[3,:])
@show abs.(Statistics.mean(pts,dims=2))
@test sum(abs.(Statistics.mean(pts,dims=2)) .< [2.0; 2.0; 2.0]) == 3
@show Statistics.std(pts,dims=2)
@test sum([0.1; 2.0; 0.01] .< Statistics.std(pts,dims=2) .< [5.0; 10.0; 2.0]) == 3

##

end

@testset "Testing Pose2Point2Bearing Initialization and Packing" begin

##

p2p2b = Pose2Point2Bearing( MvNormal([0.2,0.2,0.2], [1.0 0 0;0 1 0;0 0 1]) )
packed = convert(PackedPose2Point2Bearing, p2p2b)
p2p2bTest = convert(Pose2Point2Bearing, packed)
@test p2p2b.bearing.μ == p2p2bTest.bearing.μ
@test p2p2b.bearing.Σ.mat == p2p2bTest.bearing.Σ.mat

##

end
