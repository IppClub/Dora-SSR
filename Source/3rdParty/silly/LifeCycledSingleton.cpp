#include "LifeCycledSingleton.h"

#include <vector>
#include <memory>
#include <algorithm>

namespace silly {
  class LifeCycler {
    typedef std::unique_ptr<Life> LifeOwner;

   public:

    ~LifeCycler() {
      std::sort(lives_.begin(), lives_.end(),
        [](const LifeOwner& a, const LifeOwner& b) {
          return a->getTime() < b->getTime();
      });
    }

    void add(Life* life) {
      lives_.push_back(LifeOwner(life));
    }

    static LifeCycler& shared() {
      static LifeCycler lifeCycler;
      return lifeCycler;
    }

  private:
    std::vector<LifeOwner> lives_;
  };

  Life::Life(int time):time_(time) {
    LifeCycler::shared().add(this);
  }
} // namespace silly
