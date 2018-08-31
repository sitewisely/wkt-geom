module Data.Wkb.Polygon where

import qualified Control.Monad     as Monad
import qualified Data.Binary.Get   as BinaryGet
import qualified Data.Geospatial   as Geospatial
import qualified Data.LinearRing   as LinearRing

import qualified Data.Wkb.Endian   as Endian
import qualified Data.Wkb.Geometry as Geometry
import qualified Data.Wkb.Point    as Point

getPolygon :: Endian.EndianType -> Geometry.WkbCoordinateType -> BinaryGet.Get Geospatial.GeospatialGeometry
getPolygon endianType coordType = do
  geoPolygon <- getGeoPolygon endianType coordType
  pure $ Geospatial.Polygon geoPolygon

getMultiPolygon :: Endian.EndianType -> Geometry.WkbCoordinateType -> BinaryGet.Get Geospatial.GeospatialGeometry
getMultiPolygon endianType coordType = do
  geoPolygons <- getGeoPolygons endianType coordType
  pure $ Geospatial.MultiPolygon $ Geospatial.mergeGeoPolygons geoPolygons

getGeoPolygons :: Endian.EndianType -> Geometry.WkbCoordinateType -> BinaryGet.Get [Geospatial.GeoPolygon]
getGeoPolygons endianType coordType = do
  numberOfPolygons <- Endian.getFourBytes endianType
  Monad.forM [1..numberOfPolygons] (\_ -> getGeoPolygon endianType coordType)

getGeoPolygon :: Endian.EndianType -> Geometry.WkbCoordinateType -> BinaryGet.Get Geospatial.GeoPolygon
getGeoPolygon endianType coordType = do
  linearRings <- getLinearRings endianType coordType
  pure $ Geospatial.GeoPolygon linearRings

getLinearRings :: Endian.EndianType -> Geometry.WkbCoordinateType -> BinaryGet.Get [LinearRing.LinearRing [Double]]
getLinearRings endianType coordType = do
  numberOfRings <- Endian.getFourBytes endianType
  Monad.forM [1..numberOfRings] (\_ -> getLinearRing endianType coordType)

getLinearRing :: Endian.EndianType -> Geometry.WkbCoordinateType -> BinaryGet.Get (LinearRing.LinearRing [Double])
getLinearRing endianType coordType = do
  numberOfPoints <- Endian.getFourBytes endianType
  if numberOfPoints >= 4 then do
    p1 <- Point.getCoordPoint endianType coordType
    p2 <- Point.getCoordPoint endianType coordType
    p3 <- Point.getCoordPoint endianType coordType
    pts <- Point.getCoordPoints endianType coordType (numberOfPoints - 3)
    pure $ LinearRing.makeLinearRing p1 p2 p3 (init pts)
  else
    Monad.fail "Must have at least four points for a linear ring"
