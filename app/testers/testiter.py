
class SensorControllerSet:

    def __init__(self) -> None:
        self.controllers = []

    def add(self,new_controller):
        for controller in self.controllers:
            if(controller.sensor.pin == new_controller.sensor.pin):
                print(f'[FAILED] trying to add new controller {new_controller}')
                return False

        self.controllers.append(new_controller)
        return True
    def get(self, id):
        for i, controller in enumerate(self.controllers):
            if(controller.sensor.pin == id):
                return self.controllers[i]
        print(f'[FAILED] trying to get controller -> Sensor Pin: {id}')
        return False

    def __iter__(self):
        return self.controllers.__iter__()


set = SensorControllerSet()

for controller in set:
    print(controller)