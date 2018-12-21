-- Refer to the WKB Wikipedia page <https://en.wikipedia.org/wiki/Well-known_text#Well-known_binary>
--
-- Allows parsing of ByteString into a Geospatial Object.
--
-------------------------------------------------------------------
module Data.Wkb
  ( parseByteString
  ) where

import qualified Data.Binary.Get              as BinaryGet
import qualified Data.ByteString.Lazy         as LazyByteString
import qualified Data.Geospatial              as Geospatial

import qualified Data.Internal.Wkb.Geometry   as Geometry
import qualified Data.Internal.Wkb.Geospatial as WkbGeospatial

parseByteString :: LazyByteString.ByteString -> Either String Geospatial.GeospatialGeometry
parseByteString byteString =
  case BinaryGet.runGetOrFail
        (WkbGeospatial.geospatialGeometry Geometry.getGeometryTypeWithCoords)
        byteString of
    Left (_, _, err)                 -> Left $ "Could not parse wkb: " ++ err
    Right (_, _, geoSpatialGeometry) -> Right geoSpatialGeometry
