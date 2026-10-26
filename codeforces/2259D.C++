#include <iostream>
#include <unordered_map>
#include <algorithm>
#include <vector>

int main(){
	int tests;
	cin >> tests;
	for(int test = 0;test < tests;test++){
		int n;
		cin >> n;
		std::vector<int> v(n, -1);
		//int max_val = -1;
		for(int i = 0;i < n;i++){
			cin >> v[i];
			//max_val = std::max(max_val, val); 
		}
		std::sort(v.begin(), v.end());
		//assign to A, B, C, keep doing 
		std::unordered_map<int, int> freqs;
		//you want to balance all 3 
		for(int i = 0;i < n;i++){
			freqs[v[i]]++; 
		}
		int clamped = 0;
		for(const auto& [val, freq] : freqs){
			int clampable = std::min(0, 3 - freq);
			
		}
	}

}
