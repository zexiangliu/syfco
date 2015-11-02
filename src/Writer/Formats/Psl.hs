-----------------------------------------------------------------------------
-- |
-- Module      :  Writer.Formats.Utf8
-- License     :  MIT (see the LICENSE file)
-- Maintainer  :  Felix Klein (klein@react.uni-saarland.de)
-- 
-- Transforms a specification to a UTF8 string.
-- 
-----------------------------------------------------------------------------

module Writer.Formats.Psl
    ( writePsl
    ) where

-----------------------------------------------------------------------------

import Config
import Simplify

import Data.LTL
import Data.Error
import Data.Specification

import Writer.Eval
import Writer.Data
import Writer.Utils

-----------------------------------------------------------------------------

opNames
  :: OperatorNames

opNames = OperatorNames
  { opTrue = "true" 
  , opFalse = "false"
  , opNot = "!" 
  , opAnd = "&&" 
  , opOr = "||" 
  , opImplies = "->" 
  , opEquiv = "<->"
  , opNext = "next!" 
  , opFinally = "eventually!"
  , opGlobally = "always" 
  , opUntil = "until!"
  , opRelease = error "PSL does not support the release operator"
  , opWeak = error "PSL does not support the weak until operator"
  }

-----------------------------------------------------------------------------

-- | PSL format writer.

writePsl
  :: Configuration -> Specification -> Either Error WriteContents

writePsl c s =
  let
    d = busDelimiter c
    mode = outputMode c
  in do
    (as,is,gs) <- eval d s
    fml0 <- merge as is gs
    fml1 <- simplify (c { noWeak = True, noRelease = True }) fml0
    
    return $ WriteContents {
      mainFile = pretty mode opNames fml1,
      partitionFile = Just $ partition (fmlInputs fml1) (fmlOutputs fml1)
      }

-----------------------------------------------------------------------------

