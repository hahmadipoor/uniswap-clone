// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;
// Uni v3 core uses sol < 0.8 to suppress underflow / overflow

import "./TickMath.sol";

library Tick {
    
    struct Info {
        uint128 liquidityGross;
        int128 liquidityNet;
        uint256 feeGrowthOutside0X128;
        uint256 feeGrowthOutside1X128;
        bool initialized;
    }

   function tickSpacingToMaxLiquidityPerTick(int24 tickSpacing) internal pure returns (uint128){

        int24 minTick = (TickMath.MIN_TICK / tickSpacing) * tickSpacing; 
        int24 maxTick = (TickMath.MAX_TICK / tickSpacing) * tickSpacing; 
        uint24 numTicks = uint24((maxTick - minTick) / tickSpacing) * 1; 
        return type(uint128).max/numTicks;
    }

    function update(mapping(int24 => Info) storage self, int24 tick, int24 tickCurrent, int128 liquidityDelta, uint256 feeGrowthGlobal0X128, uint256 feeGrowthGlobal1X128, bool upper, uint128 maxLiquidity) internal returns (bool flipped) {
        
        Info storage info = self[tick];
        uint128 liquidityGrossBefore = info.liquidityGross;
        uint128 liquidityGrossAfter = liquidityDelta < 0 ? liquidityGrossBefore - uint128(-liquidityDelta) : liquidityGrossBefore + uint128(liquidityDelta);
        require(liquidityGrossAfter <= maxLiquidity, "liquidity > max");

        // flipped = (liquidityGrossBefore == 0 && liquidityGrossAfter > 0)
        //     || (liquidityGrossBefore > 0 && liquidityGrossAfter == 0);

        flipped = (liquidityGrossBefore == 0) != (liquidityGrossAfter == 0);

        if (liquidityGrossBefore == 0) {
            info.initialized = true;
        }

        info.liquidityGross = liquidityGrossAfter;

        // lower    upper
        //   |       |
        //   +       -
        //   ----> one for zero +
        //   <---- zero for one -

        info.liquidityNet = upper? info.liquidityNet - liquidityDelta : info.liquidityNet + liquidityDelta;
    }

    function clear(mapping(int24 => Info) storage self, int24 tick) internal {
        delete self[tick];
    }
}


