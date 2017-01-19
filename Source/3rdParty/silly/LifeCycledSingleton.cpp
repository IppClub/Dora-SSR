#include "LifeCycledSingleton.h"

#include <vector>
#include <memory>
#include <algorithm>

namespace silly {
  class LifeCycler {
    typedef std::unique_ptr<Life> LifeOwner;

   public:

    ~LifeCycler() {
      end();
    }

    void add(Life* life) {
      lives_.push_back(LifeOwner(life));
    }

    void remove(Life* life) {
      lives_.erase(std::remove_if(lives_.begin(), lives_.end(), [life](const LifeOwner& owner) {
        return owner.get() == life;
      }));
    }

    void end() {
      std::sort(lives_.begin(), lives_.end(),
        [](const LifeOwner& a, const LifeOwner& b) {
          return a->getTime() >= b->getTime();
      });
      while (!lives_.empty()) {
        lives_.pop_back();
      }
    }

    static inline LifeCycler& shared() {
      static LifeCycler lifeCycler;
      return lifeCycler;
    }

  private:
    std::vector<LifeOwner> lives_;
  };

Life::Life(int time):time_(time) {
  LifeCycler::shared().add(this);
}

void Life::destroy(Life* life) {
  LifeCycler::shared().remove(life);
}

} // namespace silly
