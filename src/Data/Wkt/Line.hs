module Data.Wkt.Line where

import           Control.Applicative ((<|>))
import qualified Data.Geospatial     as Geospatial
import qualified Data.LineString     as LineString
import qualified Text.Trifecta       as Trifecta

import qualified Data.Wkt            as Wkt
import qualified Data.Wkt.Point      as Point

lineString :: Trifecta.Parser Geospatial.GeoLine
lineString = do
  _ <- Trifecta.string "linestring"
  _ <- Trifecta.spaces
  Geospatial.GeoLine <$> line

multiLineString :: Trifecta.Parser Geospatial.GeoMultiLine
multiLineString = do
  _ <- Trifecta.string "multilinestring"
  _ <- Trifecta.spaces
  x <- Wkt.emptySet <|> manyLines
  pure $ Geospatial.mergeGeoLines x

manyLines :: Trifecta.Parser [Geospatial.GeoLine]
manyLines = do
  _ <- Trifecta.spaces >> Trifecta.char '('
  x <- Geospatial.GeoLine <$> line
  xs <- Trifecta.many (Trifecta.char ',' >> Trifecta.spaces >> Geospatial.GeoLine <$> line)
  _ <-  Trifecta.char ')' >> Trifecta.spaces
  pure $ x:xs

line :: Trifecta.Parser (LineString.LineString [Double])
line = do
  _ <- Trifecta.spaces >> Trifecta.char '(' >> Trifecta.spaces
  first <- Point.justPoints
  second <- commandPoint
  rest <- Trifecta.many commandPoint
  _ <- Trifecta.char ')' >> Trifecta.spaces
  pure $ LineString.makeLineString first second rest

commandPoint :: Trifecta.Parser [Double]
commandPoint = do
  _ <- Trifecta.char ','
  _ <- Trifecta.spaces
  Point.justPoints

emptyMultiLine :: Geospatial.GeoMultiLine
emptyMultiLine = Geospatial.mergeGeoLines []