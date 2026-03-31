/*
    Ethan Maher
    CS4100 - Lexical Analysis
*/
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <set>
#include <algorithm>
#include <iomanip>

using namespace std;

const int K = 9;   //k-mer length — 3 tokens x 3 digits
const int W = 4;   // window size

// Function to hash a k-mer
size_t hash_kmer(const string& kmer) {
    size_t h = 0;
    for (char c : kmer) {
        h = h * 31 + (size_t)c;
    }
    return h;
}

// Winnowing function to select fingerprints
set<size_t> winnow(const string& digit_string) {
    set<size_t> fingerprints;

    if ((int)digit_string.size() < K) {
        return fingerprints;
    }

    vector<size_t> hashes;
    // Number of k-mers in the string
    int num_kmers = (int)digit_string.size() - K + 1;

    // Generate hashes for each k-mer
    for (int i = 0; i < num_kmers; i++) {
        // Extract k-mer substring
        string kmer = digit_string.substr(i, K);
        hashes.push_back(hash_kmer(kmer));
    }

    // Select minimum hash in each window
    for (int i = 0; i <= (int)hashes.size() - W; i++) {
        size_t min_hash = hashes[i];
        for (int j = i + 1; j < i + W; j++) {
            if (hashes[j] < min_hash) {
                min_hash = hashes[j];
            }
        }
        fingerprints.insert(min_hash);
    }
    
    return fingerprints;
}

// Structs to hold submission and comparison data
struct Submission {
    string filename;
    set<size_t> fingerprints;
};

struct PairResult {
    string file1, file2;
    double score;
    size_t shared;
    size_t total;
};

bool compareResults(const PairResult& a, const PairResult& b) {
    return a.score > b.score;
}

int main() {
    // Open input file
    ifstream infile("tokens.txt");
    if (!infile.is_open()) {
        cerr << "Error: cannot open tokens.txt" << endl;
        return 1;
    }

    vector<Submission> submissions;
    string line;

    // Read submissions
    while (getline(infile, line)) {
        if (line.empty()) continue;

        istringstream iss(line);
        Submission sub;

        iss >> sub.filename;

        string token;
        string digit_string;
        // Concatenate tokens into digit string
        while (iss >> token) {
            digit_string += token;
        }

        // Compute fingerprints for submission
        sub.fingerprints = winnow(digit_string);
        submissions.push_back(sub);
    }

    vector<PairResult> results;

    // Compare pairs and calculate similarity
    for (size_t i = 0; i < submissions.size(); i++) {
        for (size_t j = i + 1; j < submissions.size(); j++) {
            // Count shared fingerprints
            size_t shared = 0;
            for (size_t fp : submissions[i].fingerprints) {
                if (submissions[j].fingerprints.count(fp) > 0) {
                    shared++;
                }
            }
            // Total unique fingerprints
            size_t total = submissions[i].fingerprints.size() + submissions[j].fingerprints.size() - shared;
            
            PairResult pr;
            pr.file1 = submissions[i].filename;
            pr.file2 = submissions[j].filename;
            pr.shared = shared;
            pr.total = total;
            // Calculate Jaccard similarity -- learned this in data analytics, thought it would work for this
            if (total == 0) {
                pr.score = 0.0;  // Avoid division by zero
            } else {
                pr.score = (double)shared / (double)total;
            }
            results.push_back(pr);
        }
    }

    // Sort results by similarity score
    sort(results.begin(), results.end(), compareResults);

    // Print plagiarism report
    cout << "CMOS Plagiarism Report" << endl;
    cout << "======================" << endl;

    for (size_t i = 0; i < results.size(); i++) {
        cout << "Rank " << i + 1 << " | "
             << results[i].file1 << " vs " << results[i].file2 << " | "
             << "Similarity: " << fixed << setprecision(4) << results[i].score << " | "
             << "Shared: " << results[i].shared << "/" << results[i].total << endl;
    }

    return 0;
}