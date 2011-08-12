{-# LANGUAGE DeriveDataTypeable #-}
-- |
-- Module    : Statistics.Distribution.Gamma
-- Copyright : (c) 2009 Bryan O'Sullivan
-- License   : BSD3
--
-- Maintainer  : bos@serpentine.com
-- Stability   : experimental
-- Portability : portable
--
-- The gamma distribution.  This is a continuous probability
-- distribution with two parameters, /k/ and &#977;. If /k/ is
-- integral, the distribution represents the sum of /k/ independent
-- exponentially distributed random variables, each of which has a
-- mean of &#977;.

module Statistics.Distribution.Gamma
    (
      GammaDistribution
    -- * Constructors
    , gammaDistr
    -- * Accessors
    , gdShape
    , gdScale
    ) where

import Data.Typeable (Typeable)
import Statistics.Constants (m_huge)
import Statistics.Math (incompleteGamma, logGamma)
import qualified Statistics.Distribution as D

-- | The gamma distribution.
data GammaDistribution = GD {
      gdShape :: {-# UNPACK #-} !Double -- ^ Shape parameter, /k/.
    , gdScale :: {-# UNPACK #-} !Double -- ^ Scale parameter, &#977;.
    } deriving (Eq, Read, Show, Typeable)

-- | Create gamma distrivution. Both shape and scale parameters must be positive.
gammaDistr :: Double            -- ^ Shape parameter. /k/
           -> Double            -- ^ Scale parameter, &#977;.
           -> GammaDistribution
gammaDistr k theta
  | k     <= 0 = error $ msg ++ "shape must be positive. Got " ++ show k
  | theta <= 0 = error $ msg ++ "scale must be positive. Got " ++ show theta
  | otherwise  = GD k theta
    where msg = "Statistics.Distribution.Gamma.gammaDistr: "
{-# INLINE gammaDistr #-}

instance D.Distribution GammaDistribution where
    cumulative = cumulative

instance D.ContDistr GammaDistribution where
    density    = density
    quantile   = quantile

instance D.Variance GammaDistribution where
    variance (GD a l) = a * l * l
    {-# INLINE variance #-}

instance D.Mean GammaDistribution where
    mean (GD a l) = a * l
    {-# INLINE mean #-}

density :: GammaDistribution -> Double -> Double
density (GD a l) x
  | x <= 0    = 0
  | otherwise = x ** (a-1) * exp (-x/l) / (exp (logGamma a) * l ** a)
{-# INLINE density #-}

cumulative :: GammaDistribution -> Double -> Double
cumulative (GD k l) x
  | x <= 0    = 0
  | otherwise = incompleteGamma k (x/l)
{-# INLINE cumulative #-}

quantile :: GammaDistribution -> Double -> Double
quantile d p
  | p == 0    = -1/0
  | p == 1    = 1/0
  | otherwise = D.findRoot d p (gdShape d) 0 m_huge
{-# INLINE quantile #-}
