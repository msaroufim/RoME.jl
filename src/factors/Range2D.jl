


"""
$(TYPEDEF)
"""
mutable struct Point2Point2Range{D <: IIF.SamplableBelief} <: IncrementalInference.AbstractRelativeMinimize
  Z::D
end

function getSample(cfo::CalcFactor{<:Point2Point2Range}, N::Int=1)
  return (reshape(rand(cfo.factor.Z,N),1,N),)
end

function (cfo::CalcFactor{<:Point2Point2Range})(rho, xi, lm)
  # Basically `EuclidDistance`
  # must return all dimensions
  return rho .- norm(lm[1:2] .- xi[1:2])
end

passTypeThrough(d::FunctionNodeData{Point2Point2Range}) = d

"""
$(TYPEDEF)
"""
mutable struct PackedPoint2Point2Range  <: IncrementalInference.PackedInferenceType
  str::String
end
function convert(::Type{PackedPoint2Point2Range}, d::Point2Point2Range)
  return PackedPoint2Point2Range(convert(PackedSamplableBelief, d.Z))
end
function convert(::Type{Point2Point2Range}, d::PackedPoint2Point2Range)
  return Point2Point2Range(convert(SamplableBelief, d.str))
end



"""
    $TYPEDEF

Range only measurement from Pose2 to Point2 variable.
"""
mutable struct Pose2Point2Range{T <: IIF.SamplableBelief} <: IIF.AbstractRelativeMinimize
  Z::T
  partial::Tuple{Int,Int}
end
Pose2Point2Range(Z::T) where {T <: IIF.SamplableBelief} = Pose2Point2Range{T}(Z, (1,2))

function getSample(cfo::CalcFactor{<:Pose2Point2Range}, N::Int=1)
  return (reshape(rand(cfo.factor.Z,N),1,N), )
end

function (cfo::CalcFactor{<:Pose2Point2Range})(rho, xi, lm)
  # Basically `EuclidDistance`
  return rho .- norm(lm[1:2] .- xi[1:2])
end


mutable struct PackedPose2Point2Range  <: IncrementalInference.PackedInferenceType
  str::String
end
function convert(::Type{PackedPose2Point2Range}, d::Pose2Point2Range)
  return PackedPose2Point2Range(convert(PackedSamplableBelief, d.Z))
end
function convert(::Type{Pose2Point2Range}, d::PackedPose2Point2Range)
  return Pose2Point2Range(convert(SamplableBelief, d.str))
end
