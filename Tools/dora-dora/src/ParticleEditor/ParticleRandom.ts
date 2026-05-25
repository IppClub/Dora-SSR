export class ParticleRandom {
	private mt = new Uint32Array(624);
	private index = 624;

	constructor(seed: number) {
		this.seed(seed);
	}

	seed(seed: number) {
		this.mt[0] = seed >>> 0;
		for (let i = 1; i < 624; i++) {
			const prev = this.mt[i - 1];
			this.mt[i] = (Math.imul(1812433253, prev ^ (prev >>> 30)) + i) >>> 0;
		}
		this.index = 624;
	}

	nextUint32() {
		if (this.index >= 624) this.twist();
		let y = this.mt[this.index++];
		y ^= y >>> 11;
		y ^= (y << 7) & 0x9d2c5680;
		y ^= (y << 15) & 0xefc60000;
		y ^= y >>> 18;
		return y >>> 0;
	}

	nextFloat() {
		return this.nextUint32() / 0xffffffff;
	}

	rand1to1() {
		return this.nextFloat() * 2 - 1;
	}

	private twist() {
		for (let i = 0; i < 624; i++) {
			const y = (this.mt[i] & 0x80000000) + (this.mt[(i + 1) % 624] & 0x7fffffff);
			let next = this.mt[(i + 397) % 624] ^ (y >>> 1);
			if ((y % 2) !== 0) next ^= 0x9908b0df;
			this.mt[i] = next >>> 0;
		}
		this.index = 0;
	}
}
