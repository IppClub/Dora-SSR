/* Copyright (c) 2017, 达达, modified by Li Jin 2022
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.*/

#include "ml/DecisionTree.h"

#include <algorithm>
#include <cassert>
#include <cmath>
#include <fstream>
#include <functional>
#include <memory>
#include <sstream>
#include <unordered_map>
#include <vector>

namespace GaGa {

#define NUM_DIFF 1.e-8

static void Trim(std::string& str) {
	if (str.empty()) return;
	str.erase(0, str.find_first_not_of(" \t\n"));
	str.erase(str.find_last_not_of(" \t\n") + 1);
}

enum class ColType {
	Numeric,
	Categorical
};

class Col {
private:
	ColType _type;

public:
	std::vector<double> values;
	std::shared_ptr<std::vector<std::string>> stringIndexer;

public:
	Col(ColType type)
		: _type(type)
		, stringIndexer(std::make_shared<std::vector<std::string>>()) { }
	virtual ~Col() { }
	virtual ColType getType() const { return _type; }
};

class Matrix {
private:
	int _rowCount;
	std::vector<Col*> _features;
	std::vector<std::unique_ptr<Col>> _data;
	std::unordered_map<std::string, int> _colIndices;
	std::vector<std::string> _colNames;
	std::vector<std::string> _featureNames;
	Col* _labelCol;

public:
	Matrix()
		: _rowCount(0)
		, _labelCol(nullptr) { }
	~Matrix() { }

	void clear() {
		_rowCount = 0;
		_labelCol = nullptr;
		_data.clear();
		_features.clear();
		_featureNames.clear();
		_colIndices.clear();
		_colNames.clear();
	}

	void load(std::string&& data) {
		std::istringstream istream(std::move(data));
		load(istream);
	}

	void loadFile(const std::string& filename) {
		std::ifstream istream(filename);
		load(istream);
	}

	int ColCount() const {
		return static_cast<int>(_data.size());
	}

	int FeatureCount() const {
		return static_cast<int>(_features.size());
	}

	int RowCount() const {
		return _rowCount;
	}

	const std::vector<std::string>& GetColNames() const {
		return _colNames;
	}

	const std::vector<std::string>& GetFeatureNames() const {
		return _featureNames;
	}

	const std::vector<Col*>& GetFeatures() const {
		return _features;
	}

	const std::vector<double>& GetLabels() const {
		return _labelCol->values;
	}

	Col* GetLabelCol() const {
		return _labelCol;
	}

	const std::string& GetFeatureName(int featureIndex) const {
		return _featureNames[featureIndex];
	}

	int GetFeatureIndex(const std::string& featureName) const {
		auto it = _colIndices.find(featureName);
		assert(it != _colIndices.end());
		return it->second;
	}

	Col* GetFeatureValues(int index) const {
		return _data[index].get();
	}

	std::unique_ptr<Col> GetUniqueFeatureValues(int featureIndex) const {
		Col* col = GetFeatureValues(featureIndex);
		switch (col->getType()) {
			case ColType::Numeric: {
				auto ncol = new Col(ColType::Numeric);
				ncol->values = col->values;
				auto& values = ncol->values;
				std::sort(values.begin(), values.end());
				values.erase(std::unique(values.begin(), values.end()), values.end());
				return std::unique_ptr<Col>(ncol);
			}
			case ColType::Categorical: {
				auto ccol = new Col(ColType::Categorical);
				for (size_t i = 0; i < col->stringIndexer->size(); i++) {
					ccol->values.push_back(static_cast<double>(i));
				}
				return std::unique_ptr<Col>(ccol);
			}
			default: assert(false); return std::unique_ptr<Col>();
		}
	}

	std::pair<std::unique_ptr<Col>, std::vector<std::vector<double>>> GetFeatureValuesScores(int featureIndex) const {
		auto uniqueCol = GetUniqueFeatureValues(featureIndex);
		auto featureCol = GetFeatureValues(featureIndex);
		std::vector<std::vector<double>> scores;
		for (const auto& value : uniqueCol->values) {
			std::vector<double> score;
			for (size_t i = 0; i < featureCol->values.size(); i++) {
				if (value == featureCol->values[i]) {
					score.push_back(_labelCol->values[i]);
				}
			}
			scores.push_back(std::move(score));
		}
		return std::make_pair(std::move(uniqueCol), std::move(scores));
	}

	std::pair<std::unique_ptr<Col>, std::vector<double>> SortedFeatureLabels(int featureIndex) const {
		auto col = GetFeatureValues(featureIndex);
		assert(col->getType() == ColType::Numeric);
		auto& values = col->values;
		std::vector<std::pair<double, double>> pairs;
		for (int i = 0; i < _rowCount; i++) {
			pairs.push_back({values[i], _labelCol->values[i]});
		}
		std::stable_sort(pairs.begin(), pairs.end(),
			[](auto a, auto b) {
				return b.first - a.first > NUM_DIFF;
			});
		std::vector<double> result;
		auto ncol = new Col(ColType::Numeric);
		for (const auto& item : pairs) {
			ncol->values.push_back(item.first);
			result.push_back(item.second);
		}
		return {std::unique_ptr<Col>(ncol), std::move(result)};
	}

	std::vector<double> GetBisectNodes(int featureIndex) const {
		std::unique_ptr<Col> featureCol;
		std::vector<double> labels;
		std::tie(featureCol, labels) = SortedFeatureLabels(featureIndex);
		std::vector<double> results;
		const auto& sortedValues = featureCol->values;
		for (int i = 0; i < static_cast<int>(sortedValues.size()) - 1; i++) {
			if (std::abs(sortedValues[i] - sortedValues[i + 1]) > NUM_DIFF && labels[i] != labels[i + 1]) {
				results.push_back((sortedValues[i] + sortedValues[i + 1]) / 2.);
			}
		}
		return results;
	}

	struct BisectPart {
		std::vector<double> lowerScores;
		std::vector<double> upperScores;
		std::vector<double> lowerValues;
		std::vector<double> upperValues;
	};

	BisectPart GetFeatureBisectParts(int featureIndex, double bisectNode) const {
		BisectPart bisectPart;
		std::unique_ptr<Col> featureCol;
		std::vector<double> labels;
		std::tie(featureCol, labels) = SortedFeatureLabels(featureIndex);
		const auto& sortedValues = featureCol->values;
		for (size_t i = 0; i < sortedValues.size(); i++) {
			if (sortedValues[i] - bisectNode < -NUM_DIFF) {
				bisectPart.lowerScores.push_back(labels[i]);
				bisectPart.lowerValues.push_back(sortedValues[i]);
			} else {
				bisectPart.upperScores.push_back(labels[i]);
				bisectPart.upperValues.push_back(sortedValues[i]);
			}
		}
		return bisectPart;
	}

	enum class ValueType {
		Upper,
		Lower,
		Categorical
	};

	bool load(const Matrix& matrix, int featureIndex, ValueType valueType, double bisectNode) {
		Col* fcol = matrix.GetFeatureValues(featureIndex);
		auto featureName = matrix.GetFeatureName(featureIndex);
		_featureNames = matrix.GetFeatureNames();
		auto it = std::remove(_featureNames.begin(), _featureNames.end(), featureName);
		_featureNames.erase(it);
		for (size_t i = 0; i < matrix._data.size(); i++) {
			if (i != featureIndex) {
				Col* col = matrix._data[i].get();
				_data.push_back(std::make_unique<Col>(col->getType()));
				_data.back()->stringIndexer = col->stringIndexer;
				if (i < matrix._data.size() - 1) {
					_features.push_back(_data.back().get());
				} else
					_labelCol = _data.back().get();
				const auto& name = matrix._colNames[i];
				_colIndices[name] = static_cast<int>(_colNames.size());
				_colNames.push_back(name);
			}
		}

		switch (fcol->getType()) {
			case ColType::Categorical: {
				assert(valueType == ValueType::Categorical);
				for (int r = 0; r < matrix._rowCount; r++) {
					if (fcol->values[r] == bisectNode) {
						_rowCount++;
						int index = 0;
						for (size_t c = 0; c < matrix._data.size(); c++) {
							if (c != featureIndex) {
								double value = matrix._data[c]->values[r];
								_data[index]->values.push_back(value);
								index++;
							}
						}
					}
				}
				break;
			}
			case ColType::Numeric: {
				switch (valueType) {
					case ValueType::Lower:
						for (int r = 0; r < matrix._rowCount; r++) {
							if (fcol->values[r] - bisectNode < -NUM_DIFF) {
								_rowCount++;
								int index = 0;
								for (size_t c = 0; c < matrix._data.size(); c++) {
									if (c != featureIndex) {
										double value = matrix._data[c]->values[r];
										_data[index]->values.push_back(value);
										index++;
									}
								}
							}
						}
						break;
					case ValueType::Upper:
						for (int r = 0; r < matrix._rowCount; r++) {
							if (fcol->values[r] - bisectNode > NUM_DIFF) {
								_rowCount++;
								int index = 0;
								for (size_t c = 0; c < matrix._data.size(); c++) {
									if (c != featureIndex) {
										double value = matrix._data[c]->values[r];
										_data[index]->values.push_back(value);
										index++;
									}
								}
							}
						}
						break;
					default:
						assert(false && "numeric column is not accepting categorical value");
						break;
				}
			}
		}
		return true;
	}

private:
	void load(std::basic_istream<char>& istream) {
		clear();
		std::string line;
		std::string item;
		int columnCount = 0;
		std::list<std::unique_ptr<std::unordered_map<std::string, int>>> uniques;
		if (!istream.eof()) {
			std::getline(istream, line);
			std::istringstream iss(line);
			int index = 0;
			while (iss.good()) {
				std::getline(iss, item, ',');
				Trim(item);
				_colIndices[item] = index;
				_colNames.push_back(item);
				index++;
				columnCount++;
				uniques.emplace_back();
			}
		} else
			throw std::logic_error("missing column names");
		if (!istream.eof()) {
			std::getline(istream, line);
			std::istringstream iss(line);
			int index = 0;
			auto uit = uniques.begin();
			while (iss.good()) {
				std::getline(iss, item, ',');
				Trim(item);
				if (item == "C") {
					_data.push_back(std::unique_ptr<Col>(new Col(ColType::Categorical)));
					*uit = std::make_unique<std::unordered_map<std::string, int>>();
				} else if (item == "N") {
					_data.push_back(std::unique_ptr<Col>(new Col(ColType::Numeric)));
				} else
					throw std::logic_error("invalid column type hint");
				index++;
				uit++;
			}
			if (index != columnCount) throw std::logic_error("numbers of column names and column count mismatch");
		} else
			throw std::logic_error("missing column hints");
		_rowCount = 0;
		while (!istream.eof()) {
			std::getline(istream, line);
			if (line.empty()) continue;
			std::istringstream iss(line);
			int index = 0;
			auto uit = uniques.begin();
			while (iss.good()) {
				std::getline(iss, item, ',');
				Trim(item);
				Col* col = _data[index].get();
				switch (col->getType()) {
					case ColType::Numeric:
						col->values.push_back(std::stod(item));
						break;
					case ColType::Categorical: {
						auto& valueSet = *uit->get();
						auto it = valueSet.find(item);
						if (it != valueSet.end()) {
							col->values.push_back(it->second);
						} else {
							int value = static_cast<int>(valueSet.size());
							valueSet[item] = value;
							col->stringIndexer->push_back(item);
							col->values.push_back(value);
						}
						break;
					}
				}
				index++;
				uit++;
			}
			if (index != columnCount) throw std::logic_error("numbers of column values and column count mismatch");
			_rowCount++;
		}
		if (_data.back()->getType() == ColType::Categorical) {
			_labelCol = _data.back().get();
		} else
			throw std::logic_error("label column must be of categorical values");
		for (size_t i = 0; i < _data.size() - 1; i++) {
			_features.push_back(_data[i].get());
			_featureNames.push_back(_colNames[i]);
		}
	}
};

static std::vector<double> UniqueValues(const std::vector<double>& values) {
	auto newValues = values;
	std::sort(newValues.begin(), newValues.end());
	newValues.erase(std::unique(newValues.begin(), newValues.end()), newValues.end());
	return newValues;
}

static double FrequentValues(const std::vector<double>& values) {
	assert(values.size() > 0);
	auto uniqueValues = UniqueValues(values);
	std::vector<int> counts(uniqueValues.size());
	for (size_t i = 0; i < values.size(); i++) {
		for (size_t j = 0; j < uniqueValues.size(); j++) {
			if (values[i] == uniqueValues[j]) {
				counts[j]++;
			}
		}
	}

	int maxCount = 0, maxIndex = 0;
	for (size_t i = 0; i < uniqueValues.size(); i++) {
		if (counts[i] > maxCount) {
			maxCount = counts[i];
			maxIndex = static_cast<int>(i);
		}
	}
	return uniqueValues[maxIndex];
}

static double ComputeScoreEntropy(const std::vector<double>& scores) {
	std::vector<double> scoreRange = UniqueValues(scores);
	if (scoreRange.size() == 0) {
		return 0;
	} else {
		double entropy = 0;
		std::vector<int> counts(scoreRange.size());
		for (size_t i = 0; i < scores.size(); i++) {
			for (size_t j = 0; j < scoreRange.size(); j++) {
				if (scores[i] == scoreRange[j]) {
					counts[j]++;
				}
			}
		}

		double tempEntropy = 0;
		double tempP = 0;
		for (size_t j = 0; j < scoreRange.size(); j++) {
			tempP = static_cast<double>(counts[j]) / static_cast<double>(scores.size());
			tempEntropy = -tempP * std::log(tempP) / std::log(2.);
			entropy += tempEntropy;
		}
		return entropy;
	}
}

static double ComputeFeatureEntropy(const Matrix& matrix, int featureIndex) {
	auto col = matrix.GetFeatureValues(featureIndex);
	return ComputeScoreEntropy(col->values);
}

static double ComputeFeatureEntropyGain(const Matrix& matrix, int featureIndex, double bisectNode) {
	double gainedEntropy = 0;
	const auto& labels = matrix.GetLabels();
	double originalEntropy = ComputeScoreEntropy(labels);
	auto col = matrix.GetFeatureValues(featureIndex);
	switch (col->getType()) {
		case ColType::Categorical: {
			std::unique_ptr<Col> uniqueValues;
			std::vector<std::vector<double>> valueScores;
			std::tie(uniqueValues, valueScores) = matrix.GetFeatureValuesScores(featureIndex);
			double afterEntropy = 0;
			double tempEntropy = 0;
			for (size_t i = 0; i < uniqueValues->values.size(); i++) {
				const auto& tempScores = valueScores[static_cast<int>(uniqueValues->values[i])];
				tempEntropy = ComputeScoreEntropy(tempScores)
							* static_cast<double>(tempScores.size())
							/ static_cast<double>(labels.size());
				afterEntropy += tempEntropy;
			}
			gainedEntropy = originalEntropy - afterEntropy;
			return gainedEntropy;
		}
		case ColType::Numeric: {
			auto parts = matrix.GetFeatureBisectParts(featureIndex, bisectNode);
			double lowerLen = static_cast<double>(parts.lowerScores.size());
			double upperLen = static_cast<double>(parts.upperScores.size());
			double len = lowerLen + upperLen;
			double afterEntropy = lowerLen / len * ComputeScoreEntropy(parts.lowerScores)
								+ upperLen / len * ComputeScoreEntropy(parts.upperScores);
			double gainedEntropy = originalEntropy - afterEntropy;
			return gainedEntropy;
		}
		default: assert(false && "invalid column type"); return 0;
	}
}

static double GainRatio(const Matrix& matrix, int featureIndex, double bisectNode) {
	double attributeEntropy = ComputeFeatureEntropy(matrix, featureIndex);
	double attributeEntropyGain = ComputeFeatureEntropyGain(matrix, featureIndex, bisectNode);
	return attributeEntropyGain / attributeEntropy;
}

using TreeHandler = std::function<void(int, const std::string&, const std::string&, const std::string&)>;

class TreeNode {
public:
	double value = 0;
	std::string op;
	std::string branch;
	std::string node;
	std::vector<std::unique_ptr<TreeNode>> children;

	static void BuildTree(TreeNode* tree, const Matrix& matrix, int depth, int maxDepth) {
		auto uniqueScores = UniqueValues(matrix.GetLabels());
		if (uniqueScores.size() == 1) {
			Col* labelCol = matrix.GetLabelCol();
			tree->node = (*labelCol->stringIndexer)[static_cast<int>(uniqueScores.back())];
			return;
		}

		if (maxDepth > 0 && depth == maxDepth) {
			const auto& labels = matrix.GetLabels();
			Col* labelCol = matrix.GetLabelCol();
			tree->node = (*labelCol->stringIndexer)[static_cast<int>(FrequentValues(labels))];
			return;
		}

		double gainRatio = 0, entropyGain = 0;
		double tempGainRatio = 0, tempEntropyGain = 0;
		double maxBisectNode = 0;
		int maxFeatureIndex = -1;
		const auto& features = matrix.GetFeatures();
		for (int i = 0; i < static_cast<int>(features.size()); i++) {
			if (features[i]->getType() == ColType::Categorical) {
				tempGainRatio = GainRatio(matrix, i, 0);
			} else if (features[i]->getType() == ColType::Numeric) {
				auto bisectNodes = matrix.GetBisectNodes(i);
				for (size_t j = 0; j < bisectNodes.size(); j++) {
					tempEntropyGain = ComputeFeatureEntropyGain(matrix, i, bisectNodes[j]);
					if (tempEntropyGain - entropyGain > NUM_DIFF) {
						entropyGain = tempEntropyGain;
						maxBisectNode = bisectNodes[j];
					}
				}
				tempGainRatio = GainRatio(matrix, i, maxBisectNode);
			}
			if (tempGainRatio - gainRatio > NUM_DIFF) {
				gainRatio = tempGainRatio;
				maxFeatureIndex = i;
			}
		}
		if (maxFeatureIndex == -1) {
			const auto& labels = matrix.GetLabels();
			if (labels.size() > 0) {
				Col* labelCol = matrix.GetLabelCol();
				tree->node = (*labelCol->stringIndexer)[static_cast<int>(FrequentValues(labels))];
			}
			return;
		}

		tree->node = matrix.GetFeatureNames()[maxFeatureIndex];
		std::vector<Matrix::ValueType> valueTypes;
		std::vector<double> values;
		std::vector<std::string> ops;
		std::vector<std::string> branchValues;
		if (features[maxFeatureIndex]->getType() == ColType::Categorical) {
			values = matrix.GetUniqueFeatureValues(maxFeatureIndex)->values;
			branchValues = *features[maxFeatureIndex]->stringIndexer;
			for (size_t i = 0; i < values.size(); i++) {
				ops.push_back("==");
				valueTypes.push_back(Matrix::ValueType::Categorical);
			}
		} else if (features[maxFeatureIndex]->getType() == ColType::Numeric) {
			values = {maxBisectNode, maxBisectNode};
			std::string branch = std::to_string(maxBisectNode);
			branchValues = {branch, branch};
			ops = {"<=", ">"};
			valueTypes = {Matrix::ValueType::Lower, Matrix::ValueType::Upper};
		} else
			assert(false && "invalid column type");

		for (size_t k = 0; k < values.size(); k++) {
			Matrix newMatrix;
			newMatrix.load(matrix, maxFeatureIndex, valueTypes[k], values[k]);
			auto newTree = std::make_unique<TreeNode>();
			newTree->op = ops[k];
			newTree->branch = branchValues[k];
			newTree->value = values[k];
			auto newUniqueScores = UniqueValues(newMatrix.GetLabels());
			if (newUniqueScores.size() == 1) {
				Col* labelCol = matrix.GetLabelCol();
				newTree->node = (*labelCol->stringIndexer)[static_cast<int>(newUniqueScores.back())];
				tree->children.push_back(std::move(newTree));
			} else if (newUniqueScores.size() > 1) {
				BuildTree(newTree.get(), newMatrix, depth + 1, maxDepth);
				tree->children.push_back(std::move(newTree));
			}
		}
	}

	void Visit(const TreeHandler& handler) {
		Visit(std::string(), -1, handler);
	}

	double TestAccuracy(const Matrix& matrix) {
		std::vector<std::string> predictions;
		Predict(matrix, predictions);
		Col* labelCol = matrix.GetLabelCol();
		size_t matched = 0;
		for (size_t i = 0; i < labelCol->values.size(); i++) {
			if (labelCol->stringIndexer->at(static_cast<size_t>(labelCol->values[i])) == predictions[i]) {
				matched++;
			}
		}
		if (predictions.size() == 0) {
			return 0.0;
		}
		return matched / static_cast<double>(predictions.size());
	}

	void Predict(const Matrix& matrix, std::vector<std::string>& predictions) const {
		for (int i = 0; i < matrix.RowCount(); i++) {
			Predict(std::string(), matrix, i, predictions);
			if (i != predictions.size() - 1) {
				predictions.emplace_back();
			}
		}
	}

private:
	void Visit(const std::string& name, int depth, const TreeHandler& handler) const {
		if (!name.empty()) {
			handler(depth, name, op, branch);
		}
		if (!children.empty()) {
			for (const auto& child : children) {
				child->Visit(node, depth + 1, handler);
			}
		} else {
			handler(depth + 1, std::string(), "return", node);
		}
	}

	void Predict(const std::string& name, const Matrix& matrix, int row, std::vector<std::string>& predictions) const {
		if (!name.empty()) {
			int featureIndex = matrix.GetFeatureIndex(name);
			Col* col = matrix.GetFeatureValues(featureIndex);
			switch (col->getType()) {
				case ColType::Categorical: {
					auto value = col->stringIndexer->at(static_cast<int>(col->values[row]));
					if (value != branch) return;
					break;
				}
				case ColType::Numeric:
					if (op == "<=" && col->values[row] - value > NUM_DIFF) return;
					if (op == ">" && col->values[row] - value <= NUM_DIFF) return;
					break;
			}
		}
		if (!children.empty()) {
			for (const auto& child : children) {
				child->Predict(node, matrix, row, predictions);
			}
		} else {
			predictions.push_back(node);
		}
	}
};

static std::pair<std::list<DecisionTree::Node>, double> BuildTestTree(const Matrix& matrix, int maxDepth) {
	std::list<DecisionTree::Node> nodes;
	auto tree = std::make_unique<TreeNode>();
	TreeNode::BuildTree(tree.get(), matrix, 1, maxDepth);
	tree->Visit(
		[&](int depth,
			const std::string& name,
			const std::string& op,
			const std::string& value) {
			nodes.push_back({depth, name, op, value});
		});
	double accuracy = tree->TestAccuracy(matrix);
	return {std::move(nodes), accuracy};
}

std::pair<std::list<DecisionTree::Node>, double> DecisionTree::BuildTest(std::string&& data, int maxDepth) {
	Matrix matrix;
	matrix.load(std::move(data));
	return BuildTestTree(matrix, maxDepth);
}

std::pair<std::list<DecisionTree::Node>, double> DecisionTree::BuildTestFromFile(const std::string& filename, int maxDepth) {
	Matrix matrix;
	matrix.loadFile(filename);
	return BuildTestTree(matrix, maxDepth);
}

} // namespace GaGa
