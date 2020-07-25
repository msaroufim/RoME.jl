
##==============================================================================
## Delete at end v0.7.x

# """
# OBSOLETE: see https://github.com/JuliaRobotics/IncrementalInference.jl/issues/237
# """
# mutable struct PartialPose3XYYawNH <: IncrementalInference.AbstractRelativeFactorNH
#   xyy::Distributions.MvNormal
#   partial::Tuple{Int, Int, Int}
#   nullhypothesis::Distributions.Categorical
#   PartialPose3XYYawNH() = new()
#   PartialPose3XYYawNH(xyy::MvNormal, vh::Vector{Float64}) = new(xyy, (1,2,6),  Distributions.Categorical(vh))
# end
# function getSample(pxyy::PartialPose3XYYawNH, N::Int=1)
#   return (rand(pxyy.xyy,N), )
# end
# function (pxyy::PartialPose3XYYawNH)(res::Array{Float64},
#             userdata,
#             idx::Int,
#             meas::Tuple{Array{Float64,2}},
#             wXi::Array{Float64,2},
#             wXj::Array{Float64,2}  )
#   #
#   wXjhat = SE2(wXi[[1;2;6],idx])*SE2(meas[1][:,idx]) #*SE2(pp2.Zij[:,1])*SE2(meas[1][:,idx])
#   jXjhat = SE2(wXj[[1;2;6],idx]) \ wXjhat
#   se2vee!(res, jXjhat)
#   nothing
# end
#
#
#
# mutable struct PackedPartialPose3XYYawNH <: IncrementalInference.PackedInferenceType
#   vecZij::Array{Float64,1} # 3translations, 3rotation
#   vecCov::Array{Float64,1}
#   nullhypothesis::Vector{Float64}
#   PackedPartialPose3XYYawNH() = new()
#   PackedPartialPose3XYYawNH(x1::Vector{Float64}, x2::Array{Float64}, x3::Vector{Float64}) = new(x1, x2[:], x3)
# end
# function convert(::Type{PartialPose3XYYawNH}, d::PackedPartialPose3XYYawNH)
#   return PartialPose3XYYawNH( Distributions.MvNormal(d.vecZij,
#                reshapeVec2Mat(d.vecCov, 3)), d.nullhypothesis  )
# end
# function convert(::Type{PackedPartialPose3XYYawNH}, d::PartialPose3XYYawNH)
#   return PackedPartialPose3XYYawNH(d.xyy.μ, d.xyy.Σ.mat, d.nullhypothesis.p )
# end
#
#
# function compare(a::PartialPose3XYYawNH, b::PartialPose3XYYawNH; tol::Float64=1e-10)
#   TP = true
#   TP = TP && norm(a.xyy.μ-b.xyy.μ) < tol
#   TP = TP && norm(a.xyy.Σ.mat[:]-b.xyy.Σ.mat[:]) < tol
#   TP = TP && norm(collect(a.partial)-collect(b.partial)) < tol
#   TP = TP && norm(a.nullhypothesis.p-b.nullhypothesis.p) < tol
#   return TP
# end




import IncrementalInference: buildFactorDefault

buildFactorDefault(::Type{Pose2Pose2}) = Pose2Pose2()
buildFactorDefault(::Type{Pose2Point2}) = Pose2Point2()
buildFactorDefault(::Type{Pose2Point2BearingRange}) = Pose2Point2BearingRange()
buildFactorDefault(::Type{Point2Point2}) = Point2Point2()


# export Pose3Pose3NH, PackedPose3Pose3NH

# -----------------------
#
# """
# $(TYPEDEF)
#
# Obsolete, see issue https://github.com/JuliaRobotics/IncrementalInference.jl/issues/237.
# """
# mutable struct Pose3Pose3NH <: IncrementalInference.AbstractRelativeFactorNH
#     Zij::Distribution
#     nullhypothesis::Distributions.Categorical
#     reuse::Vector{PP3REUSE}
#     Pose3Pose3NH() = new()
#     Pose3Pose3NH(s::Distribution, vh::Vector{Float64}) = new(s, Distributions.Categorical(vh), fill(PP3REUSE(), Threads.nthreads() )  )
#     # Pose3Pose3NH(s::SE3, c::Array{Float64,2}, vh::Float64) = new(s,c, Distributions.Categorical([(1.0-vh);vh]),SE3(0),SE3(0),SE3(0))
#     # Pose3Pose3NH(st::FloatInt, sr::Float64;vh::Float64=1.0) = new(SE3(0), [[st*Matrix{Float64}(LinearAlgebra.I, 3,3);zeros(3,3)];[zeros(3);sr*Matrix{Float64}(LinearAlgebra.I, 3,3)]], Distributions.Categorical([(1.0-vh);vh]),SE3(0),SE3(0),SE3(0))
# end
# function getSample(pp3::Pose3Pose3NH, N::Int=1)
#   return (rand(pp3.Zij, N), )
# end
# function (pp3::Pose3Pose3NH)(res::Array{Float64},
#             userdata,
#             idx::Int,
#             meas::Tuple,
#             wXi::Array{Float64,2},
#             wXj::Array{Float64,2}  )
#   #
#   reusethrid = pp3.reuse[Threads.threadid()]
#   fastpose3pose3residual!(reusethrid, res, idx, meas, wXi, wXj)
#   nothing
# end
#
#
#
# """
# $(TYPEDEF)
#
# Obsolete, see issue https://github.com/JuliaRobotics/IncrementalInference.jl/issues/237.
# """
# mutable struct PackedPose3Pose3NH <: IncrementalInference.PackedInferenceType
#   vecZij::Vector{Float64} # 3translations, 3rotation
#   vecCov::Vector{Float64}
#   dimc::Int
#   nullhypothesis::Vector{Float64}
#   PackedPose3Pose3NH() = new()
#   PackedPose3Pose3NH(x1::Vector{Float64},x2::Vector{Float64},x3::Int,x4::Vector{Float64}) = new(x1, x2, x3, x4)
# end
#
# function convert(::Type{Pose3Pose3NH}, d::PackedPose3Pose3NH)
#   qu = Quaternion(d.vecZij[4], d.vecZij[5:7])
#   se3val = SE3(d.vecZij[1:3], qu)
#   cov = reshapeVec2Mat(d.vecCov, d.dimc)
#   return Pose3Pose3NH( MvNormal(veeEuler(se3val), cov), d.nullhypothesis )
# end
# function convert(::Type{PackedPose3Pose3NH}, d::Pose3Pose3NH)
#   val = d.Zij.μ
#   se3val = SE3(val[1:3], Euler(val[4:6]...))
#   v1 = veeQuaternion(se3val)
#   v2 = d.Zij.Σ.mat
#   return PackedPose3Pose3NH(v1[:], v2[:], size(v2,1), d.nullhypothesis.p )
# end
#
#


export Point2Point2WorldBearing, PackedPoint2Point2WorldBearing
# export PriorPoint2DensityNH, PackedPriorPoint2DensityNH


"""
$(TYPEDEF)

TODO DEPRECATE
"""
mutable struct Point2Point2WorldBearing{T} <: IncrementalInference.AbstractRelativeFactor where {T <: IIF.SamplableBelief}
    Z::T
    rangemodel::Rayleigh
    # zDim::Tuple{Int, Int}
    Point2Point2WorldBearing{T}() where T = new{T}()
    Point2Point2WorldBearing{T}(x::T) where {T <: IIF.SamplableBelief} = new{T}(x, Rayleigh(100))
end
function Point2Point2WorldBearing(x::T) where {T <: IIF.SamplableBelief}
  @warn "Point2Point2WorldBearing is being deprecated, use Point2, Point2Polar or Point2BearingRange instead."
  Point2Point2WorldBearing{T}(x)
end

function getSample(pp2::Point2Point2WorldBearing, N::Int=1)
  sp = Array{Float64,2}(undef, 2,N)
  sp[1,:] = rand(pp2.Z,N)
  sp[2,:] = rand(pp2.rangemodel,N)
  return (sp, )
end
function (pp2r::Point2Point2WorldBearing)(
          res::Array{Float64},
          userdata::FactorMetadata,
          idx::Int,
          meas::Tuple,
          pi::Array{Float64,2},
          pj::Array{Float64,2} )
  #
  # noisy bearing measurement
  z, r = meas[1][1,idx], meas[1][2,idx]
  dx, dy = pj[1,idx]-pi[1,idx], pj[2,idx]-pi[2,idx]
  res[1] = z - atan(dy,dx)
  res[2] = r - norm([dx; dy])
  nothing
end




"""
$(TYPEDEF)

Serialization type for `Point2Point2WorldBearing`.
"""
mutable struct PackedPoint2Point2WorldBearing  <: IncrementalInference.PackedInferenceType
    str::String
    # NOTE Not storing rangemodel which may cause inconsistencies if the implementation parameters change
    PackedPoint2Point2WorldBearing() = new()
    PackedPoint2Point2WorldBearing(x::String) = new(x)
end
function convert(::Type{PackedPoint2Point2WorldBearing}, d::Point2Point2WorldBearing)
  return PackedPoint2Point2WorldBearing( string(d.Z) )
end
function convert(::Type{Point2Point2WorldBearing}, d::PackedPoint2Point2WorldBearing)
  return Point2Point2WorldBearing( extractdistribution(d.str) )
end

# """
# $(TYPEDEF)
#
# Will be deprecated, use `addFactor!(.., nullhypo=)` instead (work in progress)
# """
# mutable struct PriorPoint2DensityNH <: IncrementalInference.AbstractPriorNH
#   belief::BallTreeDensity
#   nullhypothesis::Distributions.Categorical
#   PriorPoint2DensityNH() = new()
#   PriorPoint2DensityNH(belief, p::Distributions.Categorical) = new(belief, p)
#   PriorPoint2DensityNH(belief, p::Vector{Float64}) = new(belief, Distributions.Categorical(p))
# end
# function getSample(p2::PriorPoint2DensityNH, N::Int=1)
#   return (rand(p2.belief, N), )
# end
#
# """
# $(TYPEDEF)
#
# Will be deprecated, use `addFactor!(.., nullhypo=)` instead (work in progress)
# """
# mutable struct PackedPriorPoint2DensityNH <: IncrementalInference.PackedInferenceType
#     rpts::Vector{Float64} # 0rotations, 1translation in each column
#     rbw::Vector{Float64}
#     dims::Int
#     nh::Vector{Float64}
#     PackedPriorPoint2DensityNH() = new()
#     PackedPriorPoint2DensityNH(x1,x2,x3, x4) = new(x1, x2, x3, x4)
# end
# function convert(::Type{PriorPoint2DensityNH}, d::PackedPriorPoint2DensityNH)
#   return PriorPoint2DensityNH(
#             manikde!(reshapeVec2Mat(d.rpts, d.dims), d.rbw, (:Euclid, :Euclid)),
#             Distributions.Categorical(d.nh)  )
# end
# function convert(::Type{PackedPriorPoint2DensityNH}, d::PriorPoint2DensityNH)
#   return PackedPriorPoint2DensityNH( getPoints(d.belief)[:], getBW(d.belief)[:,1], Ndim(d.belief), d.nullhypothesis.p )
# end
#


function PriorPoint2D(mu, cov, W)
  @warn "PriorPoint2D(mu, cov, W) is deprecated, use PriorPoint{T}(T(...)) instead -- e.g. PriorPoint2{MvNormal}(MvNormal(...) or any other Distributions.Distribution type instead."
  PriorPoint2{MvNormal{Float64}}(MvNormal(mu, cov))
end


##==============================================================================
## Delete at end v0.6.x

export nextPose

# """
#     $SIGNATURES
#
# Return a number increment on symbol.  Example :x2 -> :x3.
# """
# nextPose(sym::Symbol, identifier::Union{String, Char}=string(sym)[1]) = Symbol(string(identifier,parse(Int,string(sym)[2:end])+1))

@deprecate nextPose(sym::Symbol, identifier::Union{String, Char}=string(sym)[1]) Symbol(string(sym)[1],DFG.getVariableLabelNumber(sym)+1)



function addOdoFG!(slaml::SLAMWrapper, odo::Pose3Pose3;
                  N::Int=100, solvable::Int=1,
                  saveusrid::Int=-1)
  #
  @error("addOdoFG! is currently not usable (legacy code).")
  vprev = getVert(slaml.fg, slaml.lastposesym)
  # vprev, X, nextn = getLastPose(fgl)
  npnum = parse(Int,string(slaml.lastposesym)[2:end]) + 1
  nextn = Symbol("x$(npnum)")
  vnext = addVariable!(slaml.fg, nextn, Pose2(labels=["POSE";]), N=N, solvable=solvable)
  # vnext = addVariable!(slaml.fg, nextn, getVal(vprev) ⊕ odo, N=N, solvable=solvable, labels=["POSE"])
  slaml.lastposesym = nextn
  fact = addFactor!(slaml.fg, [vprev;vnext], odo)

  if saveusrid > -1
    slaml.lbl2usrid[nextn] = saveusrid
    slaml.usrid2lbl[saveusrid] = nextn
  end
  return vnext, fact
end


function addposeFG!(slaml::SLAMWrapper,
      constrs::Vector{IncrementalInference.FunctorInferenceType};
      N::Int=100,
      solvable::Int=1,
      saveusrid::Int=-1   )
  #
  @error("addposeFG! is currently not usable (legacy code).")
  vprev = getVert(slaml.fg, slaml.lastposesym)

  npnum = parse(Int,string(slaml.lastposesym)[2:end]) + 1
  nextn = Symbol("x$(npnum)")
  # preinit
  vnext = nothing
  if !haskey(slaml.fg.IDs, nextn)
    vnext = addVariable!(slaml.fg, nextn, Pose2, N=N, solvable=solvable, tags=[:POSE])
    # vnext = addVariable!(slaml.fg, nextn, getVal(vprev), N=N, solvable=solvable, labels=["POSE"])
  else
    vnext = getVariable(slaml.fg, nextn) # as optimization, assuming we already have latest vnest in slaml.fg
  end
  slaml.lastposesym = nextn

  addsubtype(fgl::AbstractDFG, vprev, vnext, cc::IncrementalInference.AbstractRelativeFactor) = addFactor!(fgl, [vprev;vnext], cc)
  addsubtype(fgl::AbstractDFG, vprev, vnext, cc::IncrementalInference.AbstractPrior) = addFactor!(fgl, [vnext], cc)

  facts = Graphs.ExVertex[]
  PP = BallTreeDensity[]
  for cns in constrs
    fa = addsubtype(slaml.fg, vprev, vnext, cns)
    push!(facts, fa)
  end

  # set node val from new constraints as init
  val, = predictbelief(slaml.fg, vnext, facts, N=N)
  setVal!(vnext, val)
  # IncrementalInference.dlapi.updatevertex!(slaml.fg, vnext)

  if saveusrid > -1
    slaml.lbl2usrid[nextn] = saveusrid
    slaml.usrid2lbl[saveusrid] = nextn
  end
  return vnext, facts
end


# old type interfaces

# function Point2DPoint2DRange(mu,stdev,w)
#   @warn "Point2DPoint2DRange deprecated in favor of Point2Point2Range{<:IIF.SamplableBelief}."
#   Point2Point2Range{Normal}(Normal(mu,stdev))
# end
# function Point2DPoint2D(d::D) where {D <: IIF.SamplableBelief}
#   @warn "Point2DPoint2D deprecated in favor of Point2Point2{<:Distribution}."
#   Point2Point2{D}(d)
# end
# function Point2DPoint2D(mu::Array{Float64}, cov::Array{Float64,2}, W::Array{Float64,1})
#   @warn "Point2DPoint2D deprecated in favor of Point2Point2{<:Distribution}."
#
#   Point2Point2{MvNormal}(MvNormal(mu[:], cov))
# end
#
# function Pose2DPoint2DBearing(x1::B) where {B <: Distributions.Distribution}
#   @warn "Pose2DPoint2DBearing deprecated in favor of Pose2Point2Bearing."
#   Pose2Point2Bearing(B)
# end
#
# function Pose2DPoint2DRange(x1::T,x2::Vector{T},x3) where {T <: Real}
#   @warn "Pose2Point2Range(mu,cov,w) is being deprecated in favor of Pose2Point2Range(T(...)), such as Pose2Point2Range(MvNormal(mu, cov))"
#   Pose2Point2Range(Normal(x1, x2))
# end




# old code below

# This has been moved to transform utils
# TODO Switch to using SE(2) oplus
# DX = [transx, transy, theta]
function addPose2Pose2!(retval::Array{Float64,1}, x::Array{Float64,1}, dx::Array{Float64,1})
  X = SE2(x)
  DX = SE2(dx)
  se2vee!(retval, X*DX)
  nothing
end
function addPose2Pose2(x::Array{Float64,1}, dx::Array{Float64,1})
    retval = zeros(3)
    addPose2Pose2!(retval, x, dx)
    return retval
end


function evalPotential(obs::PriorPose2, Xi::Array{Graphs.ExVertex,1}; N::Int=200)
    cov = diag(obs.Cov)
    ret = zeros(3,N)
    @warn "should not be running"
    for j in 1:N
      for i in 1:size(obs.Zi,1)
        ret[i,j] += obs.Zi[i,1] + (cov[i]*randn())
      end
    end
    return ret
end



function evalPotential(odom::Pose2Pose2, Xi::Array{Graphs.ExVertex,1}, Xid::Int; N::Int=100)
    rz,cz = size(odom.Zij)
    Xval = Array{Float64,2}()
    XvalNull = Array{Float64,2}()
    @warn "should not be running"
    # implicit equation portion -- bi-directional pairwise function
    if Xid == Xi[1].index #odom.
        #Z = (odom.Zij\Matrix{Float64}(LinearAlgebra.I, rz,rz)) # this will be used for group operations
        Z = se2vee(SE2(vec(odom.Zij)) \ Matrix{Float64}(LinearAlgebra.I, 3,3))
        Xval = getVal(Xi[2])
        XvalNull = getVal(Xi[1])
    elseif Xid == Xi[2].index
        Z = odom.Zij
        Xval = getVal(Xi[1])
        XvalNull = getVal(Xi[2])
    else
        error("Bad evalPairwise Pose2Pose2")
    end

    r,c = size(Xval)
    RES = zeros(r,c*cz)

    # TODO -- this should be the covariate error from Distributions, only using diagonals here (approxmition for speed in first implementation)
    # dd = size(Z,1) == r
    ENT = randn(r,c)
    HYP = rand(Categorical(odom.W),c) # TODO consolidate
    HYP -= length(odom.W)>1 ? 1 : 0
    for d in 1:r
       @fastmath @inbounds ENT[d,:] = ENT[d,:].*odom.Cov[d,d]
    end
    # Repeat ENT values for new modes from meas
    for j in 1:cz
      for i in 1:c
        if HYP[i]==1 # TODO consolidate hypotheses on Categorical
          z = Z[1:r,j].+ENT[1:r,i]
          RES[1:r,i*j] = addPose2Pose2(Xval[1:r,i], z )
        else
          RES[1:r,i*j] = XvalNull[1:r,i]
        end
      end
    end

    return RES
end



# to be deprecated
function pack3(xL1, xL2, p1, p2, p3, xF3)
    error("RoME.BearingRange2D:pack3 to be deprecated")
    X = zeros(3)
    X[p1] = xL1
    X[p2] = xL2
    X[p3] = xF3
    return X
end

function bearrang!(residual::Array{Float64,1}, Z::Array{Float64,1}, X::Array{Float64,1}, L::Array{Float64,1})
  @warn "bearrang! is deprecated"
  wTb = SE2(X)
  bTl = wTb\[L[1:2];1.0]
  b = atan(bTl[2],bTl[1])
  residual[1] = Z[2]-norm(bTl[1:2])
  residual[2] = Z[1]-b
  nothing
end


# should be collapsed to use only numericRootGenericRandomizedFnc
function solveLandm(Zbr::Array{Float64,1}, par::Array{Float64,1}, init::Array{Float64,1})
    return numericRoot(bearrang!, Zbr, par, init)
    # return (nlsolve(   (l, res) -> bearrang!(res, Zbr, par, l), init )).zero
end

# old numeric residual function for pose 2 to pose 2 constraint function.
function solvePose2(Zbr::Array{Float64,1}, par::Array{Float64,1}, init::Array{Float64,1})
    # TODO -- rework to ominus oplus and residual type method
    error("solvePose2 is deprecated")
    p = collect(1:3);
    shuffle!(p);
    p1 = p.==1; p2 = p.==2; p3 = p.==3
    #@show init, par
    r = nlsolve(    (res, x) -> bearrang!(res, Zbr,  pack3(x[1], x[2], p1, p2, p3, init[p3]), par),
                    [init[p1];init[p2]] )
    return pack3(r.zero[1], r.zero[2], p1, p2, p3, init[p3]);
end

function solveSetSeps(fnc::Function, Zbr::Array{Float64,1}, CovZ::Array{Float64,2},
                      pars::Array{Float64,2}, inits::Array{Float64,2})
    error("solveSetSeps is deprecated")
    out = zeros(size(inits))
    for i in 1:size(pars,2)
        ent = 1.0*[CovZ[1,1]*randn(); CovZ[2,2]*randn()]
        out[:,i] = fnc((Zbr+ent), vec(pars[:,i]), vec(inits[:,i]) )
    end
    return out
end

# Xid is the one you want to get back
function evalPotential(brpho::Pose2Point2BearingRange, Xi::Array{Graphs.ExVertex,1}, Xid::Int; N::Int=100)
    # TODO -- add null hypothesis here, might even be done one layer higher in call stack
    error("evalPotential(brpho::Pose2Point2BearingRange,...) should not be here anymore")
    val = Array{Float64,2}()
    ini = Array{Graphs.ExVertex,1}()
    par = Array{Graphs.ExVertex,1}()
    oth = Array{Graphs.ExVertex,1}()
    ff::Function = +
    nullhyp = 0.0
    # mmodes = 1 < length(brpho.W)
    # implicit equation portion -- multi-dependent function
    if Xid == Xi[1].index # brpho. ## find the pose

        ff = solvePose2
        # ini = brpho.Xi[1]
        par = Xi[2:end]
        for j in 1:(length(Xi)-1)
            push!(ini, Xi[1])
        end
        #println("Xid == brpho.Xi[1].index inits=", size(inits), ", par=", size(pars))
    elseif Xid == Xi[2].index # find landmark
        if length(Xi) > 2
            nullhyp = 0.5 # should be variable weight
            oth = Xi[3]
        end
        ff = solveLandm
        ini = Xi[2]
        par = Xi[1]
    elseif length(Xi) > 2
        nullhyp = 0.5 # should be variable weight
        if Xid == Xi[3].index # find second mode landmark
            ff = solveLandm
            ini = Xi[3]
            oth = Xi[2]
            par = Xi[1]
        end
    end
    if ff == +
        error("Bad evalPotential Pose2Point2DBearingRange")
    end

    # Gamma = Categorical(brpho.W)

    inits = getVal(ini)
    pars = getVal(par)
    others =  length(Xi) > 2 && Xid != Xi[1].index ? getVal(oth) : Union{}
    # add null hypothesis case
    len = length(Xi) > 2 && Xid != Xi[1].index ? size(others,2) : 0
    # gamma = mmodes ? rand(Gamma) : 1
    numnh = floor(Int, 2*nullhyp*len) # this doubles the value count for null cases
    nhvals = zeros(size(inits,1),numnh)
    for i in 1:numnh
        idx = floor(Int,len*rand()+1)
        # nhvals[:,i] = inits[:,idx] # WRONG! this should be the other landmark, not current landmark
        nhvals[:,i] = others[:,idx]
    end

    val = solveSetSeps(ff, vec(brpho.Zij[:,1]), brpho.Cov, pars, inits)

    return [val';nhvals']'
end

function evalPotentialNew(brpho::Pose2Point2BearingRange, Xi::Array{Graphs.ExVertex,1}, Xid::Int; N::Int=100)
    # TODO -- add null hypothesis here, might even be done one layer higher in call stack
    error("deprecated")
    val = Array{Float64,2}()
    ini = Array{Graphs.ExVertex,1}()
    par = Array{Graphs.ExVertex,1}()
    ff::Function = +
    mmodes = 1 < length(brpho.W)
    x = getVal(brpho.Xi[1])
    l1 = getVal(brpho.Xi[2])
    l2 = mmodes ? getVal(brpho.Xi[3]) : nothing
    nPts = size(x,2)

    pars = Array{Float64,2}(undef,size(x))

    # discrete option, marginalized out before message is sent
    Gamma = mmodes ? rand(Categorical(brpho.W),nPts) : ones(Int,nPts)
    L1s = Gamma .== 1
    nl1s = sum(map(Int, L1s))
    nl2s = nPts-nl1s
    # implicit equation portion -- multi-dependent function

    if Xid == brpho.Xi[1].index # find the pose
        ff = solvePose2
        # par = brpho.Xi[2:end]
        push!(ini, brpho.Xi[1])
        for j in 1:nPts
            pars[:,j] = L1s[j] ? l1[:,j] : l2[:,j]
        end
    elseif Xid == brpho.Xi[2].index # find landmark
        ff = solveLandm
        pars = x
        push!(ini,brpho.Xi[2])
    elseif mmodes
        if Xid == brpho.Xi[3].index # find second mode landmark
            ff = solveLandm
            push!(ini,brpho.Xi[3])
            pars = x
        end
    end
    if ff == +
        error("Bad evalPotential Pose2Point2DBearingRange")
    end

    inits = getVal(ini)

    L1 = sample(getKDE(brpho.Xi[2]),numsampls) #?? # TODO you where here

    len = size(inits,2)
    numnh = floor(Int, 2*nullhyp*len) # this doubles the value count for null cases
    nhvals = zeros(size(inits,1),numnh)
    for i in 1:numnh
        idx = floor(Int,len*rand()+1)
        nhvals[:,i] = inits[:,idx]
    end

    val = solveSetSeps(ff, vec(brpho.Zij[:,1]), brpho.Cov, pars, inits)

    return [val';nhvals']'
end



# Solve for Xid, given values from vertices [Xi] and measurement rho
function evalPotential(rho::Pose2Point2Range, Xi::Array{Graphs.ExVertex,1}, Xid::Int; N::Int=100)
  error("deprecated")
  fromX, ret = nothing, nothing
  if Xi[1].index == Xid
    fromX = getVal( Xi[2] )
    ret = deepcopy(getVal( Xi[1] )) # carry pose yaw row over if required
    ret[3,:] = 2*pi*rand(size(fromX,2))-pi
  elseif Xi[2].index == Xid
    fromX = getVal( Xi[1] )
    ret = deepcopy(getVal( Xi[2] )) # carry pose yaw row over if required
  end
  r,c = size(fromX)
  theta = 2*pi*rand(c)
  noisy = rho.Cov*randn(c) + rho.Zij[1]

  for i in 1:c
    ret[1,i] = noisy[i]*cos(theta[i]) + fromX[1,i]
    ret[2,i] = noisy[i]*sin(theta[i]) + fromX[2,i]
  end

  return ret
end



# should use new multihypo interface that is part of addFactor
# although use of hypothesis here might be good example for other inference situations

mutable struct Pose2Point2BearingRangeMH{B <: Distributions.Distribution, R <: Distributions.Distribution} <: IncrementalInference.AbstractRelativeFactor
    bearing::B
    range::R
    hypothesis::Distributions.Categorical
    Pose2Point2BearingRangeMH{B,R}() where {B,R} = new{B,R}()
    Pose2Point2BearingRangeMH(x1::B,x2::R, w::Distributions.Categorical) where {B,R} = new{B,R}(x1,x2,w)
    Pose2Point2BearingRangeMH(x1::B,x2::R, w::Vector{Float64}=Float64[1.0;]) where {B,R} = new{B,R}(x1,x2,Categorical(w))
end
function getSample(pp2br::Pose2Point2BearingRangeMH, N::Int=1)::Tuple{Array{Float64,2}, Vector{Int}}
  b = rand(pp2br.bearing, N)
  r = rand(pp2br.range, N)
  s = rand(pp2br.hypothesis, N)
  return ([b';r'], s)
end
# define the conditional probability constraint
function (pp2br::Pose2Point2BearingRangeMH)(res::Array{Float64},
            userdata,
            idx::Int,
            meas::Tuple{Array{Float64,2}, Vector{Int}},
            xi::Array{Float64,2},
            lms... )::Nothing  # ::Array{Float64,2}
  #
  @warn "Older interface, not analytically correct."
  res[1] = lms[meas[2][idx]][1,idx] - (meas[1][2,idx]*cos(meas[1][1,idx]+xi[3,idx]) + xi[1,idx])
  res[2] = lms[meas[2][idx]][2,idx] - (meas[1][2,idx]*sin(meas[1][1,idx]+xi[3,idx]) + xi[2,idx])
  nothing
end

mutable struct PackedPose2Point2BearingRangeMH <: IncrementalInference.PackedInferenceType
    bearstr::String
    rangstr::String
    hypostr::String
    PackedPose2Point2BearingRangeMH() = new()
    PackedPose2Point2BearingRangeMH(s1::AS, s2::AS, s3::AS) where {AS <: AbstractString} = new(string(s1),string(s2),string(s3))
end
function convert(::Type{PackedPose2Point2BearingRangeMH}, d::Pose2Point2BearingRangeMH{Normal{T}, Normal{T}}) where T
  return PackedPose2Point2BearingRangeMH(string(d.bearing), string(d.range), string(d.hypothesis))
end
# TODO -- should not be resorting to string, consider specialized code for parametric distribution types
function convert(::Type{Pose2Point2BearingRangeMH}, d::PackedPose2Point2BearingRangeMH)
  Pose2Point2BearingRangeMH(extractdistribution(d.bearstr), extractdistribution(d.rangstr), extractdistribution(d.hypostr))
end



function getNextLbl(fgl::AbstractDFG, chr)
  @warn "getNextLbl is deprecated, use nextPose, nextLabel, or getLastPoses instead."
  # TODO convert this to use a double lookup
  max = -1
  maxid = -1
  for vid in fgl.IDs
  # for v in fgl.v #fgl.g.vertices # fgl.v
      v = (vid[2], fgl.g.vertices[vid[2]])
      if v[2].attributes["label"][1] == chr
        # TODO test for allnums first, ex. :x1_2
        val = parse(Int,v[2].attributes["label"][2:end])
        if max < val
          max = val
          maxid = v[1]
        end
      end
  end
  if maxid != -1
    v = getVert(fgl,maxid)
    X = getVal(v)
    return v, X, Symbol(string(chr,max+1))
  else
    return nothing, nothing, Symbol(string(chr,max+1)) # Union{}
  end
end


function getLastPose(fgl::AbstractDFG)
  return getNextLbl(fgl, 'x')
end
getLastPose2D(fgl::AbstractDFG) = getLastPose(fgl)

function getlastpose(slam::SLAMWrapper)
  error("getlastpose -- Not implemented yet")
end


function getLastLandm2D(fgl::AbstractDFG)
  return getNextLbl(fgl, 'l')
end


function basicFactorGraphExample(::Type{Pose2}=Pose2; addlandmark::Bool=true)
  @warn "basicFactorGraphExample is deprecated, use generateCanonicalFG_TwoPoseOdo instead"
  generateCanonicalFG_TwoPoseOdo(addlandmark=addlandmark)
end


export projectParticles, ⊕




# TODO -- stronger type safety required here
# Project all particles (columns) Xval with Z, that is for all  SE3(Xval[:,i])*Z
function projectParticles(Xval::Array{Float64,2}, Z::Distribution)
  # TODO optimize for more speed with threads and better memory management
  r,c = size(Xval)
  RES = zeros(r,c) #*cz

  ent, x = SE3(0), SE3(0)
  ENT = rand( Z, c )
  # ENT = rand( MvNormal(zeros(6), Cov), c )
  j=1
  # for j in 1:cz
  for i in 1:c
    x.R = TransformUtils.convert(SO3,Euler(Xval[4,i],Xval[5,i],Xval[6,i]))
    x.t = Xval[1:3,i]
    ent.R =  TransformUtils.convert(SO3, Euler(ENT[4:6,i]...)) # so3
    ent.t = ENT[1:3,i]
    # newval = Z*ent
    # res = x*newval
    res = x*ent
    RES[1:r,i*j] = veeEuler(res)
  end
  # end
  #
  return RES
end

function ⊕(Xpts::Array{Float64,2}, z::Pose3Pose3)
  @warn "⊕ use together with projectParticles is being replaced by approxConv.  The use of ⊕ will be revived in the future."
  projectParticles(Xpts, z.Zij)
end
function ⊕(Xvert::Graphs.ExVertex, z::Pose3Pose3)
  ⊕(getVal(Xvert), z)
end



# Project all particles (columns) Xval with Z, that is for all  SE3(Xval[:,i])*Z
function projectParticles(Xval::Array{Float64,2}, Z::Array{Float64,2}, Cov::Array{Float64,2})
  # TODO optimize convert SE2 to a type
  @warn "projectParticles is an old function, rather standardize on approxConv instead."

  r,c = size(Xval)
  RES = zeros(r,c) #*cz

  # ent, x = SE3(0), SE3(0)
  j=1
  # for j in 1:cz
  ENT = rand( MvNormal(Z[:,1], Cov), c )
    for i in 1:c
      x = SE2(Xval[1:3,i])
      dx = SE2(ENT[1:3,i])
      RES[1:r,i*j] = se2vee(x*dx)
    end
  # end
  #
  return RES
end

⊕(Xpts::Array{Float64,2}, z::Pose2Pose2) = projectParticles(Xpts, z.Zij, z.Cov)
⊕(Xvert::Graphs.ExVertex, z::Pose2Pose2) = ⊕(getVal(Xvert), z)
