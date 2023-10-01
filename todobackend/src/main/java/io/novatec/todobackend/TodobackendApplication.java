package io.novatec.todobackend;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.repository.CrudRepository;
import org.springframework.web.bind.annotation.*;

import io.opentelemetry.instrumentation.annotations.SpanAttribute;
import io.opentelemetry.instrumentation.annotations.WithSpan;

import javax.persistence.Entity;
import javax.persistence.Id;
import java.util.ArrayList;
import java.util.List;

@SpringBootApplication
@RestController
public class TodobackendApplication {

	@Value("${CF_INSTANCE_GUID:not_set}")
	String cfInstance;

	@Value("${HOSTNAME:not_set}")
	String hostname;

	@Value("${spring.profiles.active: none}")
	String profile;

	@Autowired
	TodoRepository todoRepository;

	private String getInstanceId() {

		if (!hostname.equals("not_set"))
			return hostname;
		if (!cfInstance.equals("not_set"))
			return cfInstance;
		return "probably localhost";

	}

	@GetMapping("/hello")
	String hello() {

		return getInstanceId() + " Hallo, Welt ! ";

	}

	@GetMapping("/fail")
	String fail() {

		System.exit(1);
		return "fixed!";
	}

	@GetMapping("/todos/")
	List<String> getTodos(){

		List<String> todos = new ArrayList<String>();

		//for(Todo todo : todoRepository.findAll()) todos.add(todo.getTodo());
		todoRepository.findAll().forEach(todo -> todos.add(todo.getTodo()));

		return todos;
	}

	@PostMapping("/todos/{todo}")
	String addTodo(@PathVariable String todo){

		this.someUselessMethod(todo);
		//todoRepository.save(new Todo(todo));
		return todo;

	}

	@WithSpan
	String someUselessMethod(@SpanAttribute String todo){

		todoRepository.save(new Todo(todo));
		if(todo.equals("slow")){
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		} 		
		if(todo.equals("fail")){
			System.out.println("Failing ...");
			System.exit(1);
		} 
		return todo;

	}

	@DeleteMapping("/todos/{todo}")
	String removeTodo(@PathVariable String todo) {

		todoRepository.deleteById(todo);
		return "removed "+todo;

	}

	public static void main(String[] args) {
		SpringApplication.run(TodobackendApplication.class, args);
	}
}

@Entity
class Todo{

	@Id
	String todo;

	public Todo(){}

	public Todo(String todo){
		this.todo = todo;
	}

	public String getTodo(){
		return todo;
	}

	public void setTodo(String todo) {
		this.todo = todo;
	}

}

interface TodoRepository extends CrudRepository<Todo, String> {

}