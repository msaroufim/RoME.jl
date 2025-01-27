
export SpecialEuclidean


"""
$(TYPEDEF)

Rigid transform between two Pose2's, assuming (x,y,theta).

Related

Pose3Pose3, Point2Point2, MutablePose2Pose2Gaussian, DynPose2, InertialPose3
"""
struct Pose2Pose2{T <: IIF.SamplableBelief} <: IIF.AbstractRelativeRoots
  z::T
  # empty constructor
  Pose2Pose2{T}() where {T <: IIF.SamplableBelief} = new{T}()
  # regular constructor
  Pose2Pose2{T}(z1::T) where {T <: IIF.SamplableBelief} = new{T}(z1)
end
# convenience and default constructor
Pose2Pose2(z::T=MvNormal(zeros(3),LinearAlgebra.diagm([1.0;1.0;1.0]))) where {T <: IIF.SamplableBelief} = Pose2Pose2{T}(z)
Pose2Pose2(::UniformScaling) = Pose2Pose2(MvNormal(zeros(3),LinearAlgebra.diagm([1.0;1.0;1.0])))

getSample(cf::CalcFactor{<:Pose2Pose2}, N::Int=1) = (rand(cf.factor.z,N), )

function (cf::CalcFactor{<:Pose2Pose2})(meas,
                                        wxi,
                                        wxj  )
  #
  wXjhat = SE2(wxi)*SE2(meas)
  jXjhat = SE2(wxj) \ wXjhat
  return se2vee(jXjhat)
end


# NOTE, serialization support -- will be reduced to macro in future
# ------------------------------------

"""
$(TYPEDEF)
"""
mutable struct PackedPose2Pose2  <: IIF.PackedInferenceType
  datastr::String
  PackedPose2Pose2() = new()
  PackedPose2Pose2(x::String) = new(x)
end
function convert(::Type{Pose2Pose2}, d::PackedPose2Pose2)
  return Pose2Pose2(convert(SamplableBelief, d.datastr))
end
function convert(::Type{PackedPose2Pose2}, d::Pose2Pose2)
  return PackedPose2Pose2(convert(PackedSamplableBelief, d.z))
end



# FIXME, rather have separate compareDensity functions
function compare(a::Pose2Pose2,b::Pose2Pose2; tol::Float64=1e-10)
  return compareDensity(a.z, b.z)
  # TP = true
  # TP = TP && norm(a.z.μ-b.z.μ) < (tol + 1e-5)
  # TP = TP && norm(a.z.Σ.mat-b.z.Σ.mat) < tol
  # return TP
end

## Deprecated
# function Pose2Pose2(mean::Array{Float64,1}, cov::Array{Float64,2}, w::Vector{Float64})
#   @warn "Pose2Pose2(mu,cov,w) is deprecated in favor of Pose2Pose2(T(...)) -- use for example Pose2Pose2(MvNormal(mu, cov))"
#   Pose2Pose2(MvNormal(mean, cov))
# end
