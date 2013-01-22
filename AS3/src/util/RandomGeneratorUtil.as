package util
{
	public class RandomGeneratorUtil
	{
		private var seed:Number;
		
		public function RandomGeneratorUtil(seed:Number = 0) {
			if(seed == 0)
				seed = new Date().time;
			this.seed = seed;
		}
		
		public function nextRandom():Number
		{
			return seed;
		}
		
	}
}