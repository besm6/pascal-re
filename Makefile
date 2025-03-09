CXXFLAGS = -O3 -Wall

all: pascompl dtran

pascompl: pascompl.cc
	$(CXX) $(CXXFLAGS) -o $@ $< 

dtran: dtran.cc
	$(CXX) $(CXXFLAGS) -o $@ $< 

clean:
	rm -f pascompl dtran
