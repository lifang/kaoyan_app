
function check_answer(answer_id){
    if($(".hover_on").length==0){
        alert("请选择答案");
        return false;
    }
    total_step +=1
    if($(".hover_on").attr("id")==answer_id){
        success_times +=1;
        error_times=0;
    }else{
        success_times=0;
        error_times+=1;
    }
  
    if(success_times==3){
        if (level==max_level){
            send_record(max_level);  
        }else{
            window.location.href="/pretests/test_words?min_level="+ level+"&max_level="+max_level
        }
    }else if(error_times==2 || (total_step==6&&success_times!=3)){
        if (level==max_level){
            send_record(min_level);
        }else{
            window.location.href="/pretests/test_words?min_level="+ min_level+"&max_level="+level
        }
       
    }else{
        test_ids += answer_id+","
        $.ajax({
            async:true,
            type: "POST",
            url: "/pretests/other_words.js",
            data:{
                limit_ids : test_ids,
                level : level
            },
            dataType: "script",
            success : function(data) {
            }
        })
    }
}

function send_record(level){
    $.ajax({
        async:true,
        type: "POST",
        url: "/pretests/level_record",
        data:{
            fact_level : level
        },
        dataType: "json",
        success : function(data) {
            alert("欢迎进入短语测试阶段");
            window.location.href="/"
        }
    })
}